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
# load testing dbs
#
db_name = '../testing_data/test_shuffled_im_db/'
db_labels_name = '../testing_data/test_shuffled_label_db/'

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
# evaluate each network
#

#
# load the trained net 
#
#stepsize_var = 1200
#iteration = 59000

#MODEL = '../generate/jobs_places/places_%dss/deploy.prototxt' % stepsize_var
#PRETRAINED = '../generate/jobs_places/places_%dss/snapshots/places_%dss_iter_%s.caffemodel' % (stepsize_var, stepsize_var, iteration)
#MEAN = '../mean/transient_mean.binaryproto'

MODEL = '/home/rmba229/projects/deeptransient/src/generate/experiments/hybrid_1300ss/deploy.prototxt'
PRETRAINED = '/home/rmba229/projects/deeptransient/src/generate/experiments/hybrid_1300ss/snapshots/hybrid_1300ss_iter_73000.caffemodel'
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
error = np.zeros(40)
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

    # squared difference
    error += ((pred[:] - labels[ix,:]) ** 2).squeeze()
  
    ix = ix + 1

# write out to file
error = error[:] / ix
print np.average(error)
#with open(outfile, 'a+') as f:
#  f.write(str(error) + '\n')
