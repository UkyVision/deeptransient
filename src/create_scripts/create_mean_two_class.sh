#!/usr/bin/env sh
# Compute the mean image from the imagenet training leveldb
# N.B. this is available in data/ilsvrc12

/home/rmba229/projects/caffe/build/tools/compute_image_mean ../training_data/train_two_class_im_db \
  two_class_mean.binaryproto

echo "Done."
