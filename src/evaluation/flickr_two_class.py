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
# evaluate each network
#

#
# load the trained net 
#
MODEL = '../generate/experiments/twoclass/finetune_flickr_style/deploy.net' 
PRETRAINED = '../generate/experiments/twoclass/finetune_flickr_style/snapshots/finetune_flickr_style_iter_70000.caffemodel' 
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
pred_class = -1
num_correct = 0
truth_class = -1

im_files = glob.glob('/scratch/csgr222/data/flickr_usa/*.jpg')

# get all keys
for flickr_im in im_files:
  print flickr_im
  im = caffe.io.load_image(flickr_im)

  im[:,:,[0, 2]] = im[:,:,[2, 0]]

  im = caffe.io.resize_image(im, (256,256))
  im = im[:,:,[2,1,0]]
  im = im.swapaxes(0,2).swapaxes(1,2)
  im = (255*im).astype(np.uint8, copy=False)

  caffe_input = im - means
  caffe_input = caffe_input.transpose((1,2,0))
  caffe_input = caffe.io.resize_image(caffe_input, (227,227))
  caffe_input = caffe_input.transpose((2,0,1))
  caffe_input = caffe_input.reshape((1,)+caffe_input.shape)

  # push through the network
  out = net.forward_all(data=caffe_input)
  pred = out['prob'].squeeze()

  plt.subplot(1,2,1)
  plt.imshow(plt.imread(flickr_im))
  plt.axis('off')
  plt.subplot(1,2,2)
  plt.bar(xrange(0,2), [pred[0], pred[1]]) 
  plt.ylim((0,1))
  plt.xticks([0.25, 1.25], ['sunny', 'cloudy'])
  plt.title(key)
  plt.show()

  pred_class = np.argmax(pred)

  if ix % 100 == 0:
    print "Processed %d" % ix

  ix = ix + 1

