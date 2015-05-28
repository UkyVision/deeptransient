#
# estimate the margin for siamese network, margin is the average
# distance square of pairs across training data:
#

import plyvel, os, Image
import caffe
import numpy as np
from matplotlib import pyplot as plt

image_db_name = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/train/image_db/'
label_db_name = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/train/label_db/'

crop_size = 227
Nimages = 30000

model_file = '/homes/ted/Software/caffe/models/hybridCNN/hybridCNN_iter_700000.caffemodel'
deploy_file = '../../optimize/siamese/deploy.prototxt'
mean_file = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/imagenet_mean.binaryproto'


# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open(mean_file,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]
means_left = means[0:3,:,:]
means_right = means[3:,:,:]


#
# initialize network
#
caffe.set_mode_gpu()
net = caffe.Net(deploy_file, model_file, caffe.TEST)


def show_margins(dist_sqs):
  for key in dist_sqs:
    vect = np.array(dist_sqs[key])
    print '%s, mean:%f, median:%f' \
    % (key, vect.mean(), np.median(vect))



#
# evaluate testing images
#
db = plyvel.DB(image_db_name, create_if_missing=False, error_if_exists=False)
lbdb = plyvel.DB(label_db_name, create_if_missing=False, error_if_exists=False)

cnt = 0
dist_sqs = {'fc8_weather':[], 'fc8_season':[]} # same order with the labels
outblobs = dist_sqs.keys()
for key, value in db:
  
  lb_datum = caffe.io.caffe_pb2.Datum().FromString(lbdb.get(key))
  label = caffe.io.datum_to_array(lb_datum).flatten()
  
  im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
  im = caffe.io.datum_to_array(im_datum)

  # slice the top 3 channel from datum
  left_input = im[0:3, :, :] - means_left
  left_input = left_input[:, 0:crop_size, 0:crop_size]  # cropping
  left_input = left_input.reshape((1, 3, crop_size, crop_size))  # reshaping
  right_input = im[3:, :, :] - means_right
  right_input = right_input[:, 0:crop_size, 0:crop_size]  # cropping
  right_input = right_input.reshape((1, 3, crop_size, crop_size))  # reshaping

    
  # push through the network
  out_left = net.forward_all(data_left=left_input, blobs=outblobs)
  out_right = net.forward_all(data_left=right_input, blobs=outblobs)

  layer_name = outblobs[0]
  for i, x in enumerate(label):
    if not x == 0:
      layer_name = outblobs[i]
      break
    
  fl = out_left[layer_name].squeeze().flatten()
  fr = out_right[layer_name].squeeze().flatten()
  dist_sqs[layer_name].append(sum((fl-fr)**2))

  # print sum(fl), sum(fl**2)

  cnt += 1

  if cnt % 100 == 0:
    show_margins(dist_sqs)
    print cnt

  if cnt >= Nimages:
    break


lbdb.close()
db.close()

show_margins(dist_sqs)
