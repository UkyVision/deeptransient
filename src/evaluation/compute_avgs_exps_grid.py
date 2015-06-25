import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
import glob

outfile = 'data/ie_sslr_results.txt'

#
# get list of output files
#
slurms = glob.glob('../generate/jobs_ie_sslr/*/*.log')

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
  
    if iteration == []:
      continue
    #min_loss.append(min(loss))
    #min_loss_iter.append(iteration[loss.index(min(loss))])
    min_loss_iter.append(iteration[-2])
    min_loss.append(loss[iteration.index(iteration[-2])])

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
count = 0
param_1 = 500
param_2 = 0.000
for iteration in min_loss_iter:
  count += 1

  if count == 16:
    count = 1
    param_1 += 100
    param_2 = 0.0

  param_2 += 0.0001

  #
  # load the trained net 
  #
  MODEL = '../generate/jobs_ie_sslr/imagenet_expanded_sweep_%d_%s/deploy.net' % (param_1, str(param_2).rstrip('0')) 
  PRETRAINED = '../generate/jobs_ie_sslr/imagenet_expanded_sweep_%d_%s/snapshots/imagenet_expanded_iter_%s.caffemodel' % (param_1, str(param_2).rstrip('0'), iteration)
  MEAN = '../mean/transient_mean.binaryproto'

  # load the mean image 
  blob=caffe.io.caffe_pb2.BlobProto()
  file=open(MEAN,'rb')
  blob.ParseFromString(file.read())
  means = caffe.io.blobproto_to_array(blob)
  means = means[0]

  caffe.set_mode_cpu()
  net = caffe.Net(MODEL, PRETRAINED, caffe.TEST)

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
      
      if ix % 100 == 0:
        print "Processed %d" % ix

      ix = ix + 1

  # write out to file
  error = error[:] / ix
  with open(outfile, 'a+') as f:
    f.write(str(param_1) + ' ' + str(param_2) + ' ' + str(iteration) + ' ' + str(np.average(error)) + '\n')
  print param_1, param_2, np.average(error)
