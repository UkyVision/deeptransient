import os
import sys
import os.path as path
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt
from pprint import pprint as pp

def vis_square(data, padsize=1, padval=0):
  data -= data.min()
  data /= data.max()
              
  # force the number of filters to be square
  n = int(np.ceil(np.sqrt(data.shape[0])))
  padding = ((0, n ** 2 - data.shape[0]), (0, padsize), (0, padsize)) +  ((0, 0),) * (data.ndim - 3)
  data = np.pad(data, padding, mode='constant', constant_values=(padval, padval))
      
  # tile the filters into an image
  data = data.reshape((n, n) + data.shape[1:]).transpose((0, 2, 1, 3) + tuple(range(4, data.ndim + 1)))
  data = data.reshape((n * data.shape[1], n * data.shape[3]) + data.shape[4:])
  
  plt.imshow(data)
  plt.axis('off')

db_name = '../testing_data/testing_im/'
db_labels_name = '../testing_data/testing_label/'

#
# load labels
#
labels = np.ndarray(shape=(1,1,1,40))
db_labels = lmdb.open(db_labels_name)

with db_labels.begin(write=False) as db_labels_txn:
	for (key, value) in db_labels_txn.cursor():
		label_datum = caffe.io.caffe_pb2.Datum().FromString(value)
		lbl = caffe.io.datum_to_array(label_datum)
		lbl = lbl.swapaxes(0,2).swapaxes(0,1)
		labels = np.vstack((labels, [lbl]))

#
# load the trained net 
#

MODEL = '/home/rmba229/projects/deep_transient/src/prototxts/caffenet/deploy.prototxt'
#PRETRAINED = '/home/rmba229/projects/deep_transient/src/prototxts/caffenet/snapshots/caffenet_transient_iter_73000.caffemodel'
PRETRAINED = '/home/rmba229/projects/deep_transient/src/prototxts/caffenet/caffenet_pretrained.caffemodel'
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
db = lmdb.open(db_name)

# get all keys
with db.begin(write=False) as db_txn:
  for (key, value) in db_txn.cursor():
    dir = key.split('.')[0].replace('/','_')
    if key == '00019919/20120905_165227.jpg':
      print dir
      try:
        os.mkdir(dir)
      except:
        pass

      im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
      im = caffe.io.datum_to_array(im_datum)
      im = im.swapaxes(0,2).swapaxes(0,1)

      #plt.imshow(im)
      #plt.show()

      # let caffe subtract mean and resize for me
      caffe_input = net.preprocess('data', im)
      caffe_input = caffe_input.reshape((1,)+caffe_input.shape)
      
      # push through the network
      out = net.forward_all(data=caffe_input)
      pred = out['fc8-t'].squeeze()

      #pp([(k, v[0].data.shape) for k, v in net.params.items()])

      filters = net.params['conv1'][0].data
      vis_square(filters.transpose(0, 3, 2, 1))
      #plt.show()
      plt.savefig(path.join(dir, 'conv1' + '_weights' + '.pdf'))

      #pp([(k, v.data.shape) for k, v in net.blobs.items()])

      for k, v in net.blobs.items():
        feat = net.blobs[k].data[0]
        vis_square(feat, padval=1)
        #plt.show()
        plt.savefig(path.join(dir, k + '_blob' + '.pdf'))

      sys.stdout.flush()
