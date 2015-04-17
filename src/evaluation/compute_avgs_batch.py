import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
import glob

stepsize_var = 0
outfile = 'data/caffenet_weather_100ss_results.txt'

#
# get list of output files
#
slurms = glob.glob('../generate/jobs/**/*.out')

#
# search for minimum loss and its 
# iteration in each output file
#
min_loss = []
min_loss_iter = []
for slurm in slurms:
  loss = [] 
  iteration = []
  with open(slurm, 'r') as f:
    for line in f:
      if 'Testing net' in line:
        iteration.append(line.split()[5][:-1])
      if 'Test net output' in line:
        loss.append(line.split()[10])
    
    min_loss.append(min(loss))
    min_loss_iter.append(iteration[loss.index(min(loss))])

#
# load testing dbs
#
db_name = '../testing_data/test_deepweather_im_db/'
db_labels_name = '../testing_data/test_deepweather_label_db/'

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
for iteration in min_loss_iter:
  stepsize_var += 100

  #
  # load the trained net 
  #

  #MODEL = '../prototxts/caffenet_frozen_phase2/deploy.prototxt'
  #PRETRAINED = '../prototxts/caffenet_frozen_phase2/snapshots/caffenet_slow_fp2_iter_55000.caffemodel'
  #MEAN = '../mean/transient_mean.binaryproto'
  MODEL = '../generate/jobs/caffenet_weather_%dss/deploy.prototxt' % stepsize_var
  PRETRAINED = '../generate/jobs/caffenet_weather_%dss/snapshots/caffenet_weather_%dss_iter_%s.caffemodel' % (stepsize_var, stepsize_var, iteration)
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
  error = np.zeros(16)
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
      pred = out['fc8-t'].squeeze()
      # squared difference
      error += ((pred[:] - labels[ix,:]) ** 2).squeeze()
    
      ix = ix + 1

  # write out to file
  error = error[:] / ix
  with open(outfile, 'a+') as f:
    f.write(str(stepsize_var) + ' ' + str(iteration) + ' ' + str(np.average(error)) + '\n')
  print stepsize_var, np.average(error)
