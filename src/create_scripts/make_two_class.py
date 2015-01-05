import os
import csv
import lmdb
import caffe
import numpy as np

BASE_DIR =  '/home/rmba229/workspace/twoclassweather/weather_database/'

def make_database(db_name, files, sub_dir):

  im_db_name = db_name + '_im_db'

  if os.path.isdir(im_db_name):
    raise Exception(im_db_name + ' already exists. Delete it')

  # open the database for writing
  im_db = lmdb.Environment(im_db_name, map_size=1000000000000)

  # output image file size
  sz = (256, 256)

  with im_db.begin(write=True) as im_db_txn:
    for idx, file in enumerate(files):
      # load the image (RGB)
      im = caffe.io.load_image(BASE_DIR + sub_dir + file)
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

      # insert into the database 
      im_db_txn.put(file, im_str)
    
      if idx % 500 == 0:
        print "processed %d of %d (%s)" % (idx, len(files), db_name)


with open('data/sunny.txt','r') as f:
  sunny_filenames = [x.strip() for x in f.readlines()]
with open('data/cloudy.txt','r') as f:
  cloudy_filenames = [x.strip() for x in f.readlines()]

make_database('sunny', sunny_filenames, 'sunny/')
make_database('cloudy', cloudy_filenames, 'cloudy/')

