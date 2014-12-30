#!/usr/bin/env sh
# Compute the mean image from the imagenet training leveldb
# N.B. this is available in data/ilsvrc12

/home/rmba229/projects/caffe/build/tools/compute_image_mean ../training_data/random_train_im_db \
  transient_mean.binaryproto

echo "Done."
