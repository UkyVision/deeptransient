import os, sys, lmdb
import caffe
import numpy as np
import lmdb
from matplotlib import pyplot as plt

db_name = '/u/eag-d1/scratch/ted/deeptransient/lmdbs/siamese/train/image_db/'


#
# evaluate testing images
#
db = lmdb.open(db_name, readonly=True); db_txn = db.begin(buffers=True)

ix = 0
for key, value in db.begin().cursor():
  im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
  ims = caffe.io.datum_to_array(im_datum)

  ims = ims.swapaxes(0,1).swapaxes(1,2)
  print ims.shape
  im1 = ims[:,:,[2,1,0]]
  im2 = ims[:,:,[5,4,3]]

  # visualize
  plt.figure(11)
  plt.subplot(121)
  plt.imshow(im1)
  plt.subplot(122)
  plt.imshow(im2)
  plt.show()

db.close()
