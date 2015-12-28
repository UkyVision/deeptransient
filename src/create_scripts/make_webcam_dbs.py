#
# for making dbs out of AMOS images
#

import os
import csv
import lmdb
import glob
import caffe
import random
import numpy as np
from matplotlib import pyplot as plt

BASE_DIR =  '/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/'

def make_database(db_name, files):

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
      try:
        im = caffe.io.load_image(file[7:])
      except:
        continue

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
        print "%s: processed %d of %d (%s)" % (db_name, idx, len(files), db_name)


for direc in os.listdir(BASE_DIR):
  ims = glob.glob(BASE_DIR + direc + '/**/*.jpg')
  
  for ix,im in enumerate(ims):
    ims[ix] = os.path.abspath(im)

  random.shuffle(ims)
  filenames = ["%06d_%s" % (idx, name) for idx, name in enumerate(ims)]

  make_database(direc, filenames)
