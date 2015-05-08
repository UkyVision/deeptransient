import os
import caffe
import random
import glob
import numpy as np
import lmdb
import h5py 
from collections import defaultdict


dataset = '00000162'
base_dir = '/u/eag-d1/scratch/ryan/webcams/'

if dataset == '00000162':
  out_dir  = '%s%s/features/' % (base_dir, dataset)
  im_db = '../webcam_dbs/00000162_im_db/'
else:
  raise Exception('unknown dataset provided')


#
# load the trained net 
#

base_dir = '../caffemodels/'

#iter = 9000 

jobs = [
  {
   'name': 'transientneth',
   #'iter': iter,
   'mean': '../mean/transient_mean.binaryproto'
  },
]

job = jobs[0]

out_dir += '%s/' % (job['name'])#, iter)
if not os.path.exists(out_dir):
  os.makedirs(out_dir)

#job_dir = '%sjobs/%s/' % (base_dir, job['name'])
deploy_file = '../caffemodels/deploy.prototxt'# % job_dir
model_file = '../caffemodels/%s.caffemodel' % (job['name']) 
mean_file = job['mean'] 

# load the mean images
blob=caffe.io.caffe_pb2.BlobProto()
file=open(mean_file,'rb')
blob.ParseFromString(file.read())
means = caffe.io.blobproto_to_array(blob)
mean = means[0]

caffe.set_mode_gpu()
net = caffe.Net(deploy_file, model_file, caffe.TEST)

#
# setup for batch processing 
#

batch_size = 64 
   
def chunks(cursor, n, last_key):
  """ Yield successive n-sized chunks from the database."""
  batch = []
  for idx, (key, value) in enumerate(cursor.iternext()):
    batch.append((key, value))
    if (len(batch) == n) | (key == last_key):
      yield batch 
      batch = []

def compute_features(db_name, means, blobs, out_h5file):
  db = lmdb.open(db_name)

  image_ids = []
  features = defaultdict(list) 

  with db.begin(write=False) as db_txn:
    with db_txn.cursor() as db_cursor:
      
      # get the last key
      db_cursor.last()
      last_key = db_cursor.key()
      db_cursor.first()
      
      for idx, batch in enumerate(chunks(db_cursor, batch_size, last_key)):
        # key range of current batch
        start_key = batch[0][0]
        end_key = batch[-1][0]
        
        # initialize array to hold images 
        images = np.zeros((len(batch),3,)+(227,227))
        for idy, (key, value) in enumerate(batch):
          im_datum = caffe.io.caffe_pb2.Datum().FromString(value)
          im = caffe.io.datum_to_array(im_datum)
       
          # subtract mean & resize
          caffe_input = im - mean
          caffe_input = caffe_input.transpose((1,2,0))
          caffe_input = caffe.io.resize_image(caffe_input, (227,227))

          caffe_input = caffe_input.transpose((2,0,1))
          caffe_input = caffe_input.reshape((1,)+caffe_input.shape)
         
          # store preprocessed images
          image_ids.append(int(key[:5]))
          images[idy,:,:,:] = caffe_input

        # push through the network
        out = net.forward_all(data=images, blobs=blobs)
        
        for blob_name in blobs:
          features[blob_name].append(out[blob_name])

        print "(%s) processed batch %d (%s, %s)" % (db_name, idx+1, start_key, end_key)

    for blob_name in blobs:
      with h5py.File('%s%s_%s.h5' % (out_dir, out_h5file, blob_name)) as hf:
        hf['image_ids'] = image_ids 
        hf['features'] = np.vstack(features[blob_name]) 

#
# generate features 
#

blobs = ['fc8-t']
#blobs = ['fc7']

if dataset == '00000162':
  compute_features(im_db, mean, blobs, 'transientneth_features')
