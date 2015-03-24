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

#
# make run script
#

run_header = '#!/bin/bash'
run_template = 'cd %s; sbatch %s'

with open('run_all_jobs.sh', 'w') as f:
  f.write(run_header + '\n')

for job in jobs:
  with open('run_all_jobs.sh', 'a') as f:
    f.write(run_template % (os.path.abspath(os.path.join(jobs_root, job['name'])), os.path.abspath(os.path.join(jobs_root, job['name'], 'submit.sh'))) + '\n')

