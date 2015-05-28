#
# extract images from leveldb and export them
# predict images with deep network, run pca on the outputs,
# save the result in order
#

import os, glob, random, h5py
from PIL import Image
import caffe
import numpy as np
from scipy import misc
from matplotlib import pyplot as plt

iscutout = False
netDir = '../../optimize/baseline/'
in_blob = 'data'
out_blobs = ['fc8-feat']

model_file = netDir + 'snapshot_iter_65000.caffemodel'
# model_file = '/homes/ted/Software/caffe/models/bvlc_alexnet/bvlc_alexnet.caffemodel'
# mean_file = '/u/eag-d1/scratch/ted/webcamattri/leveldbs/imagenet_mean.binaryproto'
mean_file = '/homes/ted/Software/caffe/models/hybridCNN/hybridCNN_mean.binaryproto'

deploy_file = netDir + 'deploy.prototxt'

#
# use default model
#


# webcam_dir = '/u/eag-d1/data/transient/transient/imageAlignedLD/00000064/'
webcam_dir = '/u/eag-d1/data/transient/transient/imageAlignedLD/'

#
# read image list
#
image_list = glob.glob(webcam_dir + '**/*.jpg')
random.shuffle(image_list)
Nimages = min(1000, len(image_list))

image_size = 256
crop_size = 227

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

ix = 0
imageNames = []
for key, name in enumerate(image_list):

  im = plt.imread(name)

  if iscutout:
    # randomly crop 256x256 cutout from image
    scaler = 5; # ther greater the number, the smaller cutout is in the original image.
    im = misc.imresize(im, (image_size*scaler, image_size*scaler))
    topleft = [random.randrange(0, image_size*(scaler-1)-1),
               random.randrange(0, image_size*(scaler-1)-1)]
    im = im[topleft[0]:topleft[0]+image_size, topleft[1]:topleft[1]+image_size, :]
  else:
    im = misc.imresize(im, (image_size, image_size))


  thumb = im.copy()
  im = im[:,:,[2,1,0]]                                 # RGB -> BGR                               
  im = im.swapaxes(0,2).swapaxes(1,2)                  # swap axis                                
  im = im - means                                      # subtract mean                            
  im = im[:,0:crop_size,0:crop_size]                   # cropping                                 
  im = im.reshape((1,) + im.shape)                     # reshaping    
    
  # push through the network
  blob_args = {in_blob:im, 'blobs':out_blobs}
  out = net.forward_all(**blob_args)
  pred = []
  for outblob in out_blobs:
    pred = np.append(pred, out[outblob].squeeze().flatten())

  if ix == 0:
    siamese_out = np.zeros((len(pred), Nimages))
  
  siamese_out[:,ix] = pred

  # save images
  im = Image.fromarray(thumb)
  imageNames.append('imgs/'+str(ix)+'.jpg')
  im.save(imageNames[-1])

  ix += 1
  print '{} / {} images done.'.format(ix, Nimages)

  if ix >= Nimages:
    break

  # # visualize
  # plt.figure(11)
  # plt.subplot(131)
  # plt.imshow(thumb)
  # plt.subplot(132)
  # plt.barh(range(len(pred)), pred, align='center')
  # plt.title('prediction')
  # plt.show()



# save predictions
with h5py.File('predictions.h5', 'w') as hf:
  hf['name'] = imageNames
  hf['feat'] = siamese_out
