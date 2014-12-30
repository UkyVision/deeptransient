import os
import csv
import lmdb
import caffe
import numpy as np

BASE_DIR =  '/scratch/nja224/transient/'

def make_database(db_name, files, map):

  im_db_name = db_name + '_im_db'
  label_db_name = db_name + '_label_db'

  if os.path.isdir(im_db_name):
    raise Exception(im_db_name + ' already exists. Delete it')
  if os.path.isdir(label_db_name):
    raise Exception(label_db_name + ' already exists. Delete it')

  # open the database for writing
  im_db = lmdb.Environment(im_db_name, map_size=1000000000000)
  label_db = lmdb.Environment(label_db_name, map_size=1000000000000)

  # output image file size
  sz = (256, 256)

  with im_db.begin(write=True) as im_db_txn:
    with label_db.begin(write=True) as label_db_txn:
      for idx, file in enumerate(files):
        # get the label
        label = np.asarray(map[file], dtype=np.float)
        
        # make the label N x 1 x 1
        label = label.reshape(label.shape + (1,1))

        # load the image (RGB)
        im = caffe.io.load_image(BASE_DIR + 'imageAlignedLD/' + file)
        im = caffe.io.resize_image(im, sz)

        # channel swap for pre-trained (RGB -> BGR)
        im = im[:, :, [2,1,0]]
        
        # make channels x height x width
        im = im.swapaxes(0,2).swapaxes(1,2)
      
        # convert to uint8
        im = (255*im).astype(np.uint8, copy=False) 
     
        # image to datum 
        im_datum = caffe.io.array_to_datum(im)
        im_datum.ClearField('label')
        im_str = im_datum.SerializeToString()

        # label to datum
        label_datum = caffe.io.array_to_datum(label)
        label_datum.ClearField('label')
        label_str = label_datum.SerializeToString()
      
        # insert into the database 
        im_db_txn.put(file, im_str)
        label_db_txn.put(file, label_str)
      
        if idx % 500 == 0:
          print "processed %d of %d (%s)" % (idx, len(files), db_name)


with open(BASE_DIR + 'holdout_split/training.txt','r') as f:
  train_holdout_filenames = [x.strip() for x in f.readlines()]
with open(BASE_DIR + 'holdout_split/test.txt','r') as f:
  test_holdout_filenames = [x.strip() for x in f.readlines()]
with open(BASE_DIR + 'random_split/training.txt','r') as f:
  train_random_filenames = [x.strip() for x in f.readlines()]
with open(BASE_DIR + 'random_split/test.txt','r') as f:
  test_random_filenames = [x.strip() for x in f.readlines()]

map = {}
with open(BASE_DIR + 'annotations/annotations.tsv','r') as f:
  tsvin = csv.reader(f, delimiter='\t')
  for row in tsvin:
    filename = row[0].strip()
    # ignore confidence scores
    labels = [float(x.split(',')[0]) for x in row[1:]]
    map[filename] = labels

make_database('train', train_holdout_filenames, map)
make_database('test', test_holdout_filenames, map)
make_database('random_train', train_random_filenames, map)
make_database('random_test', test_random_filenames, map)

