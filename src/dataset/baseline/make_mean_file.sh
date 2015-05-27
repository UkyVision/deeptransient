#!/usr/bin/env sh
# Compute the mean image from the imagenet training leveldb
# N.B. this is available in data/ilsvrc12

MAKE_MEAN_BIN=$CAFFE_DIR/build/tools/compute_image_mean.bin
database=/u/eag-d1/scratch/ted/deeptransient/lmdbs/baseline/train/image_db
mean_output=/u/eag-d1/scratch/ted/deeptransient/lmdbs/baseline/mean.binaryproto

$MAKE_MEAN_BIN -backend lmdb $database $mean_output

echo "Done."
