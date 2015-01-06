import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt

db_name = '../testing_data/cloudy_im_db/'

#
# load the trained net 
#

MODEL = '../prototxts/places_500/deploy.prototxt'
PRETRAINED = '../prototxts/places_500/snapshots/places_100_transient_iter_53000.caffemodel'
MEAN = '../mean/two_class_cloudy_mean.binaryproto'

# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open(MEAN,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]

net = caffe.Classifier(MODEL, PRETRAINED,
    mean=means)
net.set_phase_test()
net.set_mode_cpu()

#
# process 
#
ix = 0
error = np.zeros(40)
db = lmdb.open(db_name)

# predicted weather class
# 0 - sunny
# 1 - cloudy
weather_class = -1

# get all keys
with db.begin(write=False) as db_txn:
  for (key, value) in db_txn.cursor():
    im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
    im = caffe.io.datum_to_array(im_datum)
    im = im.swapaxes(0,2).swapaxes(0,1)

    # let caffe subtract mean and resize for me
    caffe_input = net.preprocess('data', im)
    caffe_input = caffe_input.reshape((1,)+caffe_input.shape)
    
		# push through the network
    out = net.forward_all(data=caffe_input)
    pred = out['fc8-t'].squeeze()

    if pred[5] > pred[6]:
      weather_class = 0
    else:
      weather_class = 1
  
    print weather_class
    sys.stdout.flush()

    ix = ix + 1
