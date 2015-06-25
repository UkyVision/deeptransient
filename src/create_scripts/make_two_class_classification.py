import os
import csv
import lmdb
import caffe
import numpy as np

BASE_DIR =  '/home/rmba229/workspace/twoclassweather/weather_database/'

def make_database(db_name, files, labels):
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
        label = np.asarray(labels[idx], dtype=np.float)
         
        # make the label N x 1 x 1
        label = label.reshape(label.shape + (1,1,1))
        
        # load the image (RGB)
        im = caffe.io.load_image(BASE_DIR + file[6:])
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

def split(round):
  with open('data/sunny.txt','r') as f:
    sunny_filenames = [x.strip() for x in f.readlines()]
  with open('data/cloudy.txt','r') as f:
    cloudy_filenames = [x.strip() for x in f.readlines()]

  sunny_ims = ["%s%s" % ('sunny/', name) for idx, name in enumerate(sunny_filenames)]
  cloudy_ims = ["%s%s" % ('cloudy/', name) for idx, name in enumerate(cloudy_filenames)]

  sunny_labels = np.zeros((np.size(sunny_ims), 1))
  sunny_labels[:,0] = 0

  cloudy_labels = np.zeros((np.size(cloudy_ims), 1))
  cloudy_labels[:,0] = 1

  data_ims = np.concatenate((sunny_ims, cloudy_ims), axis=1)
  data_ims = data_ims.reshape(np.size(data_ims, 0), 1)
  data_labels = np.concatenate((sunny_labels, cloudy_labels), axis=0)
  data = np.concatenate((data_ims, data_labels), axis=1)
  np.random.shuffle(data)

  train_data = data[:np.size(data,0) * 0.8] 
  test_data = data[np.size(data,0) * 0.8:]

  np.random.shuffle(train_data)
  np.random.shuffle(test_data)

  train_data[:,0] = ["%05d_%s" % (idx, name) for idx, name in enumerate(train_data[:,0])]
  test_data[:,0] = ["%05d_%s" % (idx, name) for idx, name in enumerate(test_data[:,0])]

  make_database('train_tc_wds_%d' % round, train_data[:,0], train_data[:,1])
  make_database('test_tc_wds_%d' % round, test_data[:,0], test_data[:,1])

for ix in xrange(1,6):
  split(ix)
