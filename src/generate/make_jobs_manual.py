#
# - makes necessary files for a set of jobs
# - makes scripts to submit via sbatch
#

import os
import lmdb
import subprocess

template_root = os.path.abspath('./templates/') + '/'
caffenet_root = os.path.abspath('%scaffenet/' % template_root) + '/'
jobs_root = os.path.abspath('./jobs/') + '/'

#
# setup jobs
#

jobs = [
  {
    'name': 'caffenet_500ss',
    'base_lr': '0.001',
    'gamma': '0.9',
    'stepsize': '500',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_500ss',
  },
  {
    'name': 'caffenet_1500ss',
    'base_lr': '0.001',
    'gamma': '0.9',
    'stepsize': '1500',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_1500ss',
  },
  {
    'name': 'caffenet_2000ss',
    'base_lr': '0.001',
    'gamma': '0.9',
    'stepsize': '2000',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_2000ss',
  },
  {
    'name': 'caffenet_0005lr',
    'base_lr': '0.0005',
    'gamma': '0.9',
    'stepsize': '1000',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_0005lr',
  },
  {
    'name': 'caffenet_99g',
    'base_lr': '0.001',
    'gamma': '0.99',
    'stepsize': '1000',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_99g',
  },
]

def safe_mkdir(root):
  if not os.path.isdir(root):
    os.makedirs(root)

safe_mkdir(jobs_root)

#
# process jobs
#

for job in jobs:
  
  job_path = jobs_root + job['name'] + '/'
  subprocess.call(['cp', '-r', caffenet_root, job_path])

  with open('%ssolver_template.prototxt' % template_root, 'r') as f:
    solver_proto = f.readlines()
    
    
  # make new solver
  solver_file = job_path + 'solver.prototxt'
  
  with open(solver_file, 'w') as f:
    for line in solver_proto:
      line = line.replace('BASE_LR', job['base_lr'])
      line = line.replace('GAMMA', job['gamma'])
      line = line.replace('STEPSIZE', job['stepsize'])
      line = line.replace('SNAPSHOT_ITER', job['snapshot_iter'])
      line = line.replace('SNAPSHOT_PREFIX', job['snapshot_prefix'])
      f.write(line)
  log_file = jobs_root + job['name'] + '/' + job['name'] + '.out'
  job_files.append([solver_file, log_file, 'caffenet_pretrained.caffemodel', job['name']])



#
# templates
#

train_header_tmpl = """#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --partition=GPU
#SBATCH -J cv_%003.0f

CAFFE=~/bin/caffe/bin/caffe.bin
"""
train_job_tmpl = """
cd %s; srun -n 1 --output="%s" $CAFFE train -gpu %d --solver=%s &
"""
train_job_tmpl_finetune = """
cd %s; srun -n 1 --output="%s" $CAFFE train -gpu %d --solver=%s --weights=%s &
"""
train_footer_tmpl = """
wait
"""


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
  for (i,batch) in enumerate(batcher(job_files,2)):
    sbatch_file = jobs_root + 'start_training_%003.0f.sh' % (i)
    with open(sbatch_file, 'w') as f:
      f.write(train_header_tmpl % (i))
      for (igpu, files) in enumerate(batch):
        solver, log, model, name = files
        if model:
          f.write(train_job_tmpl_finetune % (os.path.abspath(os.path.join(jobs_root, name)), log, igpu, solver, model))
        else:
          f.write(train_job_tmpl % (name, log, igpu, solver))
      f.write(train_footer_tmpl)
    f_all.write('sbatch %s\n' % (sbatch_file))

