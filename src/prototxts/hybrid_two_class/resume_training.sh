#!/usr/bin/env sh

~/projects/caffe/build/tools/caffe train \
    -solver solver.prototxt \
    -snapshot snapshots/hybrid_two_class_iter_5000.solverstate

