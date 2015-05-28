import os, sys, lmdb
import caffe
import numpy as np
import lmdb
from matplotlib import pyplot as plt

db_name = '/scratch/mzh234/deeptransient/lmdbs/transient/test_shuffled_im_db/'
db_labels_name = '/scratch/mzh234/deeptransient/lmdbs/transient/test_shuffled_label_db/'

crop_size = 227

mean_file = '/scratch/mzh234/deeptransient/lmdbs/siamese/mean.binaryproto'

# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open(mean_file,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]
means = means[0:3,:,:]


def evaluate_database(deploy_file, model_file, means, feat_name, output):

  #
  # open file
  #
  try:
    fid = open(output, 'w')
  except:
    sys.exit(1)
  
  caffe.set_mode_gpu()
  net = caffe.Net(deploy_file, model_file, caffe.TEST)
  
  
  #
  # evaluate testing images
  #
  db = lmdb.open(db_name, readonly=True); db_txn = db.begin(buffers=True)
  label_db = lmdb.open(db_labels_name, readonly=True)
  
  ix = 0
  for key, value in label_db.begin().cursor():
    label_datum = caffe.io.caffe_pb2.Datum().FromString(value)
    label = caffe.io.datum_to_array(label_datum).flatten()
  
    im_datum = caffe.io.caffe_pb2.Datum().FromString(db_txn.get(key))
    im = caffe.io.datum_to_array(im_datum)
  
    # slice the top 3 channel from datum
    caffe_input = im[0:3, :, :] - means
    caffe_input = caffe_input[:, 0:crop_size, 0:crop_size]  # cropping
    caffe_input = caffe_input.reshape((1, 3, crop_size, crop_size))  # reshaping
      
    # push through the network
    out = net.forward_all(data=caffe_input)
    pred = out[feat_name].squeeze().flatten()
  
    error = ((pred - label) ** 2)
  
    ix += 1
    print ix, error.mean()

    error_str = ' '.join([str(x) for x in error])
    fid.write(error_str + '\n')

    # # visualize
    # img_rgb = im[0:3,:,:].swapaxes(0,2).swapaxes(0,1)
    # img_rgb = img_rgb[:,:,[2,1,0]]
    # plt.figure(11)
    # plt.subplot(131)
    # plt.imshow(img_rgb)
    # plt.subplot(132)
    # plt.barh(range(len(label)), label, align='center')
    # plt.title('ground truth')
    # plt.subplot(133)
    # plt.barh(range(len(pred)), pred, align='center')
    # plt.title('prediction')
    # plt.show()
  
  
  label_db.close()
  db.close()
  fid.close()



#
# Implement different net-model 
#

evaluate_database('../../optimize/partial_siamese/deploy.prototxt', \
                 '../../optimize/partial_siamese/snapshot_iter_16000.caffemodel', \
                 means, 'fc8-t', 'data/siamese_err.txt')

# evaluate_database('/u/eag-d1/scratch/ryan/transient/caffemodels/deploy.prototxt', \
#                  '/u/eag-d1/scratch/ryan/transient/caffemodels/transientneth.caffemodel', \
#                  means, 'fc8-t', 'data/deeptransient_err.txt')
