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
        im = caffe.io.load_image(BASE_DIR + file)
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


with open('data/sunny.txt','r') as f:
  sunny_filenames = [x.strip() for x in f.readlines()]
with open('data/cloudy.txt','r') as f:
  cloudy_filenames = [x.strip() for x in f.readlines()]

temp_dir = np.chararray(np.size(sunny_filenames), itemsize=6)
temp_dir[:] = 'sunny/'
sunny_filenames = np.core.defchararray.add(temp_dir, sunny_filenames)

temp_dir_c = np.chararray(np.size(cloudy_filenames), itemsize=7)
temp_dir_c[:] = 'cloudy/'
cloudy_filenames = np.core.defchararray.add(temp_dir_c, cloudy_filenames)

sunny_train = sunny_filenames[0:int(np.size(sunny_filenames) * 0.8)]
sunny_test = sunny_filenames[int(np.size(sunny_filenames) * 0.8):]

cloudy_train = cloudy_filenames[0:int(np.size(cloudy_filenames) * 0.8)]
cloudy_test = cloudy_filenames[int(np.size(cloudy_filenames) * 0.8):]

sunny_train_labels = np.zeros(np.size(sunny_train))
sunny_test_labels = np.zeros(np.size(sunny_test))

cloudy_train_labels = np.ones(np.size(cloudy_train))
cloudy_test_labels = np.ones(np.size(cloudy_test))

train_data = np.concatenate((sunny_train, cloudy_train), axis=0)
test_data = np.concatenate((sunny_test, cloudy_test), axis=0)
train_data_labels = np.concatenate((sunny_train_labels, cloudy_train_labels), axis=0)
test_data_labels = np.concatenate((sunny_test_labels, cloudy_test_labels), axis=0)

make_database('train_two_class', train_data, train_data_labels)
make_database('test_two_class', test_data, test_data_labels)

