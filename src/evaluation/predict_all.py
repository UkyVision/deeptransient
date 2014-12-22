import os
import caffe
import numpy as np
import matplotlib.pyplot as plt
import h5py

# load the mean image 
blob=caffe.io.caffe_pb2.BlobProto()
file=open('../mean/transient_mean.binaryproto','rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
means = means[0]

#
# load the classifier
#

net = caffe.Classifier(
  '../prototxts/caffenet/deploy.prototxt', 
  '../prototxts/caffenet/snapshots/caffenet_transient_iter_1000.caffemodel',
  mean=means,
  channel_swap=(2,1,0),
  image_dims=(320,480), 
  raw_scale=255,
  gpu=True)

net.set_phase_test()

#
# load image and run it through the network 
#

image_base = '/scratch/nja224/transient/imageAlignedLD/'

with h5py.File('train.labels.h5', 'r') as label_file:
  labels = label_file['label'].value.squeeze()

err = 0.0

with open('/scratch/nja224/transient/holdout_split/test.txt', 'r') as test_files:
  for (idx, fname) in enumerate(test_files.readlines()):
    fname = os.path.join(image_base,fname).strip()
    print fname

    input_image = caffe.io.load_image(fname)

    prediction = net.predict([input_image])
    err += ((prediction[0] - labels[idx,:]) ** 2).mean()

    #f, (ax1,ax2) = plt.subplots(1,2)
    #ax1.imshow(input_image)
    #ax2.plot(labels[idx,:],color='g')
    #ax2.plot(prediction[0],color='r')
    #plt.show()
    
    print err / (idx + 1)

