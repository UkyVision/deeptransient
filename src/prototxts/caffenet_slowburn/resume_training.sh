#!/usr/bin/env sh

../../build/tools/caffe train \
    -solver solver.prototxt \
    -snapshot models/weather_train_iter_230000.solverstate

