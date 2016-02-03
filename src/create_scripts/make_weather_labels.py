#
# for pruning the transient attrs down 
# to only weather related attributes
#

import os
import csv
import lmdb
import caffe
import random
import numpy as np
from matplotlib import pyplot as plt

BASE_DIR =  '/scratch/rmba229/transient_weather/'

with open(BASE_DIR + 'annotations/annotations.tsv','r') as f:
  tsvin = csv.reader(f, delimiter='\t')
  with open(BASE_DIR + 'annotations/weather_annotations.tsv', 'a+') as g:
    tsvout = csv.writer(g, delimiter='\t')
    for row in tsvin:
      new_row = [row[0], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[16], row[17], row[18], row[19], row[27], row[28], row[29], row[30], row[31]] 
      tsvout.writerow(new_row)

print "Done"
