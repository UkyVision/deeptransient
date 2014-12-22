#!/usr/bin/env sh
# Compute the mean image from the imagenet training leveldb
# N.B. this is available in data/ilsvrc12

/home/rmba229/projects/caffe/build/tools/compute_image_mean ../training_data/training_image \
  transient_mean.binaryproto

echo "Done."
