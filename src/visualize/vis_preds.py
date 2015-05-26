import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
import glob
import sys


#
# load testing dbs
#
db_name = '../webcam_dbs/00000623_im_db/'

#
# evaluate each network
#

#
# load the trained net 
#

MODEL = '../caffemodels/deploy.prototxt'
PRETRAINED = '../caffemodels/transientneth.caffemodel'
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

attributes = np.genfromtxt("data/attributes.txt", dtype='str')

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
    
    plt.subplot(2,1,1)
    plt.imshow(plt.imread(key[7:]))
    plt.subplot(2,1,2)
    plt.bar(xrange(0,40), pred)
    plt.xticks(xrange(0,40), attributes, rotation=90)
    plt.ylim((0,1))
    plt.show()

    ix = ix + 1

