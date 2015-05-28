#
# extract images from leveldb and export them
# predict images with deep network, run pca on the outputs,
# save the result in order
#

import plyvel, os, h5py
from PIL import Image
import caffe
import numpy as np
from matplotlib import pyplot as plt

db_name = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/test/image_db/'

crop_size = 227
Nimages = 1000

model_file = '../../optimize/siamese/snapshot_iter_70000.caffemodel'
# model_file = '/homes/ted/Software/caffe/models/bvlc_alexnet/bvlc_alexnet.caffemodel'
deploy_file = '../../optimize/siamese/deploy.prototxt'
mean_file = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/imagenet_mean.binaryproto'

out_blobs = ['fc8_weather', 'fc8_season']


#
# mkdir
#
if not os.path.exists('imgs'):
  os.mkdir('imgs')


# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open(mean_file,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]
means = means[0:3,:,:]


#
# initialize network
#
caffe.set_mode_gpu()
net = caffe.Net(deploy_file, model_file, caffe.TEST)


#
# evaluate testing images
#
db = plyvel.DB(db_name, create_if_missing=False, error_if_exists=False)

ix = 0
imageNames = []
for key, value in db:

  im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
  im = caffe.io.datum_to_array(im_datum)

  # slice the top 3 channel from datum
  caffe_input = im[0:3, :, :] - means
  caffe_input = caffe_input[:, 0:crop_size, 0:crop_size]  # cropping
  caffe_input = caffe_input.reshape((1, 3, crop_size, crop_size))  # reshaping
    
  # push through the network
  out = net.forward_all(data_left=caffe_input, blobs = out_blobs)

  pred = []
  for outblob in out_blobs:
    pred = np.append(pred, out[outblob].squeeze().flatten())
  
  img_rgb = im[0:3,:,:].swapaxes(0,2).swapaxes(0,1)
  img_rgb = img_rgb[:,:,[2,1,0]]

  if ix == 0:
    siamese_out = np.zeros((len(pred), Nimages))
  
  siamese_out[:,ix] = pred

  # save images
  im = Image.fromarray(thumb)
  imageNames.append('imgs/'+str(ix)+'.jpg')
  im.save(imageNames[-1])

  ix += 1
  print '{} prediction done.'.format(ix)

  if ix >= Nimages:
    break

  # # visualize
  # plt.figure(11)
  # plt.subplot(131)
  # plt.imshow(img_rgb)
  # plt.subplot(132)
  # plt.barh(range(len(pred)), pred, align='center')
  # plt.title('prediction')
  # plt.show()


db.close()

# save predictions
with h5py.File('predictions.h5', 'w') as hf:
  hf['name'] = imageNames
  hf['feat'] = siamese_out
