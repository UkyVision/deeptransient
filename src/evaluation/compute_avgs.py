import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt

db_name = '../testing_data/testing_im/'
db_labels_name = '../testing_data/testing_label/'

#
# load labels
#
labels = []
db_labels = lmdb.open(db_labels_name)

with db_labels.begin(write=False) as db_labels_txn:
  for (key, value) in db_labels_txn.cursor():
    label_datum = caffe.io.caffe_pb2.Datum().FromString(value)
    lbl = caffe.io.datum_to_array(label_datum)
    lbl = lbl.swapaxes(0,2).swapaxes(0,1)
    labels.append(lbl)

labels = np.vstack(labels)


#
# load the trained net 
#

MODEL = '../prototxts/caffenet/deploy.prototxt'
PRETRAINED = '../prototxts/caffenet/snapshots/caffenet_transient_iter_73000.caffemodel'
MEAN = '../mean/transient_mean.binaryproto'

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
    #pred = out['fc8-t'].squeeze()
    pred = out['fc8-t'].squeeze()

    error += ((pred[:] - labels[ix,:]) ** 2).squeeze()
  
    #print ix 
    sys.stdout.flush()

    ix = ix + 1

error = error[:] / ix
print error
