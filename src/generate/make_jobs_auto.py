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

# auto generate stepsizes in a specified range
jobs = [
  {
    'name': 'caffenet_%dss',
    'base_lr': '0.001',
    'gamma': '0.99',
    'stepsize': 'variable',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/caffenet_%dss',
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
  for stepsize in range(100, 3000, 100):

    job_path = jobs_root + job['name'] % stepsize + '/'
    subprocess.call(['cp', '-r', caffenet_root, job_path])

    with open('%ssolver_template.prototxt' % template_root, 'r') as f:
      solver_proto = f.readlines()
      
      
    # make new solver
    solver_file = job_path + 'solver.prototxt'
    
    with open(solver_file, 'w') as f:
      for line in solver_proto:
        line = line.replace('BASE_LR', job['base_lr'])
        line = line.replace('GAMMA', job['gamma'])
        line = line.replace('STEPSIZE', str(stepsize))
        line = line.replace('SNAPSHOT_ITER', job['snapshot_iter'])
        line = line.replace('SNAPSHOT_PREFIX', job['snapshot_prefix'] % stepsize)
        f.write(line)

#
# make run script
#

run_header = '#!/bin/bash'
run_template = 'cd %s; sbatch %s'

with open('run_all_jobs.sh', 'w') as f:
  f.write(run_header + '\n')

for job in jobs:
  for stepsize in range(100, 3000, 100):
    with open('run_all_jobs.sh', 'a') as f:
      f.write(run_template % (os.path.abspath(os.path.join(jobs_root, job['name'] % stepsize)), os.path.abspath(os.path.join(jobs_root, job['name'] % stepsize, 'submit.sh'))) + '\n')

