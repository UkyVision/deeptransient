import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
import glob
import sys

outfile = sys.argv[1]

#
# db name
#
db_name = '/u/amo-d0/grad/rbalten/research/deeptransient/src/webcam_dbs/7371_new/'


#
# save attr predictions from network
#

#
# load the trained net 
#

MODEL = '/u/amo-d0/grad/rbalten/research/deeptransient/src/caffemodels/deploy.prototxt'
PRETRAINED = '/u/amo-d0/grad/rbalten/research/deeptransient/src/caffemodels/transientneth.caffemodel'
MEAN = '../mean/transient_mean.binaryproto'

# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open(MEAN,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]

caffe.set_mode_cpu()
net = caffe.Classifier(MODEL, PRETRAINED, caffe.TEST)

#
# process 
#
ix = 0
db = lmdb.open(db_name)

# get all keys
with db.begin(write=False) as db_txn:
  for (key, value) in db_txn.cursor():
    im_datum = caffe.io.caffe_pb2.Datum()
    im_datum.ParseFromString(value)
    im = caffe.io.datum_to_array(im_datum)

    # subtract mean & resize
    caffe_input = im - means
    caffe_input = caffe_input.transpose((1,2,0))
    caffe_input = caffe.io.resize_image(caffe_input, (227,227))
    caffe_input = caffe_input.transpose((2,0,1))
    caffe_input = caffe_input.reshape((1,)+caffe_input.shape)

    # push through the network
    out = net.forward_all(data=caffe_input)
    pred = out['fc8-t'].squeeze()

    # save out the attributes 
    with open(outfile, 'a+') as fname:
      fname.write(key[7:] + ',')
      i = 0
      for attr in pred:
        i += 1
        if i < 40:
          fname.write(str(attr))
          fname.write(',')
        else:
          fname.write(str(attr))
          fname.write('\n')


    ix = ix + 1

    if ix % 500 == 0:
      print 'Processed %d' % ix
