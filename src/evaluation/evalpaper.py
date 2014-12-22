import os
import sys
import caffe
import numpy as np
import lmdb
import h5py
from matplotlib import pyplot as plt

db_name = '../testing_data/testing_im/'
db_labels_name = '../testing_data/testing_label/'

#
# load labels
#
labels = np.ndarray(shape=(1,1,1,40))
db_labels = lmdb.open(db_labels_name)

with db_labels.begin(write=False) as db_labels_txn:
	for (key, value) in db_labels_txn.cursor():
		label_datum = caffe.io.caffe_pb2.Datum().FromString(value)
		lbl = caffe.io.datum_to_array(label_datum)
		lbl = lbl.swapaxes(0,2).swapaxes(0,1)
		labels = np.vstack((labels, [lbl]))

# load paper data
predictions = np.loadtxt(open("paper.txt","rb"),delimiter=",")

#
# process 
#
ix = 0
error = 0
db = lmdb.open(db_name)

# get all keys
with db.begin(write=False) as db_txn:
  for (key, value) in db_txn.cursor():
    error = ((predictions[ix] - labels[ix,:]) ** 2).mean()
    
    print error #/ (ix + 1)
    sys.stdout.flush()

    ix = ix + 1
