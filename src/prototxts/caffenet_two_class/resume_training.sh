#!/usr/bin/env sh

~/projects/caffe/build/tools/caffe train \
    -solver solver.prototxt \
    -snapshot snapshots/caffenet_two_class_iter_5000.solverstate

