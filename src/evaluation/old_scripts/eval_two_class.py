import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
import time

db_name = '../testing_data/test_two_class_im_db/'
db_labels_name = '../testing_data/test_two_class_label_db/'

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

MODEL = '../generate/experiments/places_two_class/deploy.prototxt'
PRETRAINED = '../generate/experiments/places_two_class/snapshots/places_two_class_iter_32000.caffemodel'
MEAN = '../mean/two_class_mean.binaryproto'

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
pred_class = -1
truth_class = -1
num_correct = 0
total_time = 0

# get all keys
with db.begin(write=False) as db_txn:
  for (key, value) in db_txn.cursor():
    start = time.time()
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

    if pred[0] > pred[1]:
      pred_class = 0
    else:
      pred_class = 1
    
    if labels[ix,0,0] > labels[ix,0,1]:
      truth_class = 0
    else:
      truth_class = 1
    
    end = time.time()
    pred_time = end - start
    total_time += pred_time

    if pred_class == truth_class:
      num_correct += 1

    if ix % 100 == 0:
      print "Processed %d" % ix

    ix = ix + 1

#print total_time / ix

acc = float(num_correct) / ix
norm_acc = max((acc - 0.5) / (1 - 0.5), 0)

# write out to file
print 'Number Correct: %d' % num_correct
print 'Accuracy: %f' % acc
print 'Normalized Accuracy: %f' % norm_acc

