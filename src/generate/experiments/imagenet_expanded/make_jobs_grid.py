#
# - makes necessary files for a set of jobs
# - makes scripts to submit via sbatch
#

import os
import lmdb
import numpy as np

dataset_root = '/scratch/mzh234/deeptransient/lmdbs/imagenet/'
template_root = os.path.abspath('./templates/') + '/'
jobs_root = '/home/rmba229/projects/deeptransient/src/generate/jobs_ie_sslr/'

#
# setup jobs
#

train_batch_size_ = 50
test_batch_size_ = 50
computation_mode_ = 'GPU'
mean_file_ = dataset_root + 'mean.binaryproto'
model_file_ = '/scratch/mzh234/deeptransient/caffemodels/transientneth.caffemodel'

jobs = [
  {
    'name': 'imagenet_expanded_sweep',
    'model_file': model_file_,

    # template
    'train_file': 'train.net',
    'deploy_file': 'deploy.net',
    'solver_file': 'solver.prototxt',

    # macros in template
    'train': {'MEAN_FILE_': mean_file_,
              'IMAGE_DB_TRAIN_': dataset_root + 'train/image_db',
              'LABEL_DB_TRAIN_': dataset_root + 'train/label_db',
              'IMAGE_DB_TEST_': '/scratch/mzh234/deeptransient/lmdbs/transient/test_shuffled_im_db',
              'LABEL_DB_TEST_': '/scratch/mzh234/deeptransient/lmdbs/transient/test_shuffled_label_db',
              'TRAIN_BATCH_': train_batch_size_,
              'TEST_BATCH_': test_batch_size_,
            },
    'solver': {'COMPUTATION_MODE_': computation_mode_,
               'STEP_SIZE_': 'variable',
               'BASE_LR_': 'variable'},
    'common': {'IMAGE_SIZE_': 256, 'CROP_SIZE_': 227},
  },
  
]

def frange(x, y, jump):
  while x < y:
    yield x
    x += jump

def safe_mkdir(root):
  if not os.path.isdir(root):
    os.makedirs(root)

safe_mkdir(jobs_root)

#
# templates
#

train_header_tmpl = """#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --partition=GPU
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -J sslr_%003.0f

CAFFE=~/bin/caffe/bin/caffe.bin
"""
train_job_tmpl = """
cd %s; srun -n 1 --output="%s" $CAFFE train -gpu %d --solver=%s &
"""
train_job_tmpl_finetune = """
cd %s; srun -n 1 --output="%s" $CAFFE train -gpu %d --solver=%s --weights=%s &
"""
train_job_tmpl_resume = """
#cd %s; srun -n 1 --output="%s" $CAFFE train -gpu %d --solver=%s --snapshot=%s &
"""
train_footer_tmpl = """
wait
"""

local_header_tmpl = """#!/usr/bin/env sh

CAFFE=~/software/caffe/build/tools/caffe.bin
"""
local_job_tmpl = """
$CAFFE train --solver=%s 2>&1 | tee "%s"
"""
local_job_tmpl_finetune = """
$CAFFE train --solver=%s --weights=%s 2>&1 | tee "%s"
"""
local_job_tmpl_resume = """
#$CAFFE train --solver=%s --snapshot=%s 2>&1 | tee "%s"
"""


#
# process jobs
#

job_files = []
for job in jobs:
  for stepsize in xrange(500, 2000, 100):
    for base_lr in frange(0.0001, 0.0015, 0.0001): 

      job_path = jobs_root + job['name'] + '_' + str(stepsize) + '_' + str(base_lr) + '/'
      safe_mkdir(job_path)
      safe_mkdir(job_path + 'snapshots/')

      with open(template_root + job['train_file'], 'r') as f:
        train_net = f.readlines()
      with open(template_root + job['deploy_file'], 'r') as f:
        deploy_net = f.readlines()
      with open(template_root + job['solver_file'], 'r') as f:
        solver_proto = f.readlines()
        
      # make new network 
      train_file = job_path + 'train.net'

      with open(train_file, 'w') as f:
        for line in train_net:
          if 'train' in job:
            for key in job['train'].keys():
              line = line.replace(key, str(job['train'][key]))
          if 'common' in job:
            for key in job['common'].keys():
              line = line.replace(key, str(job['common'][key]))
          f.write(line)
      
      # make new deploy
      deploy_file = job_path + 'deploy.net'
      
      with open(deploy_file, 'w') as f:
        for line in deploy_net:
          if 'deploy' in job:
            for key in job['deploy'].keys():
              line = line.replace(key, str(job['deploy'][key]))
          if 'common' in job:
            for key in job['common'].keys():
              line = line.replace(key, str(job['common'][key]))
          f.write(line)
        
      # make new solver
      solver_file = job_path + 'solver.prototxt'
      
      with open(solver_file, 'w') as f:
        for line in solver_proto:
          line = line.replace('NETWORK_FILE', train_file)
          line = line.replace('SNAPSHOT_PREFIX', '%ssnapshots/%s' % (job_path, job['name']))
          if 'solver' in job:
            for key in job['solver'].keys():
              line = line.replace(key, str(job['solver'][key]))
              line = line.replace('STEPSIZE', str(stepsize))
              line = line.replace('BASE_LR', str(base_lr))
          # if 'common' in job:
          #   for key in job['common'].keys():
          #     line = line.replace(key, str(job['common'][key]))
          f.write(line)

      # for resuming
      snapshot_file = '%ssnapshots/%s_iter_1000.solverstate' % (job_path, job['name'])
      
      # store solver, model, & log file
      model_file = None
      if 'model_file' in job:
        model_file = job['model_file']
      log_file = jobs_root + job['name'] + '_' + str(stepsize) + '_' + str(base_lr) + '/output.log'
      job_name = job['name'] + '_' + str(stepsize) + '_' + str(base_lr)
      job_files.append([solver_file, model_file, log_file, snapshot_file, job_name])

#
# make local job scripts
#

for i, job in enumerate(job_files):
  local_file = jobs_root + 'local_training_%003.0f.sh' % (i)
  with open(local_file, 'w') as f:
    f.write(local_header_tmpl)
    solver, model, log, snapshot, name = job
    if model:
      f.write(local_job_tmpl_finetune % (solver, model, log))
    else:
      f.write(local_job_tmpl % (solver, log))
    f.write(local_job_tmpl_resume % (solver, snapshot, log))

#
# make supercomputer job submission scripts (grouping onto nodes)
#

from itertools import islice, chain

def batcher(iterable, size):
    sourceiter = iter(iterable)
    while True:
        batchiter = islice(sourceiter, size)
        yield chain([batchiter.next()], batchiter)

with open(jobs_root + '/run_all_jobs.sh', 'w') as f_all:
  f_all.write("#!/bin/bash\n")
  for (i,batch) in enumerate(batcher(job_files,6)):
    sbatch_file = jobs_root + 'start_training_%003.0f.sh' % (i)
    with open(sbatch_file, 'w') as f:
      f.write(train_header_tmpl % (i))
      for (igpu, files) in enumerate(batch):
        solver, model, log, snapshot, name = files
        if model:
          f.write(train_job_tmpl_finetune % (os.path.abspath(os.path.join(jobs_root, name)), log, igpu % 2, solver, model))
        else:
          f.write(train_job_tmpl % (log, igpu, solver))
        f.write(train_job_tmpl_resume % (os.path.abspath(os.path.join(jobs_root, name)), log, igpu % 2, solver, snapshot))
      f.write(train_footer_tmpl)
    f_all.write('sbatch %s\n' % (sbatch_file))

