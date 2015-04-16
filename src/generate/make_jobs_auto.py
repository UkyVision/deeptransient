#
# - makes necessary files for a set of jobs
# - makes scripts to submit via sbatch
#

import os
import lmdb
import subprocess

network_to_use = 'hybrid'

model_file = '%s_pretrained.caffemodel'
template_root = os.path.abspath('./templates/') + '/'
caffenet_root = os.path.abspath('%scaffenet/' % template_root) + '/'
places_root = os.path.abspath('%splaces/' % template_root) + '/'
hybrid_root = os.path.abspath('%shybrid/' % template_root) + '/'
jobs_root = os.path.abspath('./jobs_hybrid/') + '/'

#
# setup jobs
#

# auto generate stepsizes in a specified range
jobs = [
  {
    'name': '%s_%dss',
    'base_lr': '0.001',
    'gamma': '0.99',
    'stepsize': 'variable',
    'snapshot_iter': '1000',
    'snapshot_prefix': 'snapshots/%s_%dss',
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
# process jobs
#

job_files = []
for job in jobs:
  for var in frange(100, 3000, 100):

    job_path = jobs_root + job['name'] % (network_to_use, var) + '/'
    if network_to_use == 'caffenet':
      subprocess.call(['cp', '-r', caffenet_root, job_path])
    elif network_to_use == 'places':
      subprocess.call(['cp', '-r', places_root, job_path])
    elif network_to_use == 'hybrid':
      subprocess.call(['cp', '-r', hybrid_root, job_path])

    with open('%ssolver_template.prototxt' % template_root, 'r') as f:
      solver_proto = f.readlines()
      
      
    # make new solver
    solver_file = job_path + 'solver.prototxt'
    
    with open(solver_file, 'w') as f:
      for line in solver_proto:
        line = line.replace('BASE_LR', job['base_lr'])
        line = line.replace('GAMMA', job['gamma'])
        line = line.replace('STEPSIZE', str(var))
        line = line.replace('SNAPSHOT_ITER', job['snapshot_iter'])
        line = line.replace('SNAPSHOT_PREFIX', job['snapshot_prefix'] % (network_to_use, var))
        f.write(line)
    log_file = jobs_root + job['name'] % (network_to_use, var) + '/' + job['name'] % (network_to_use, var) + '.out'
    job_files.append([solver_file, log_file, model_file % network_to_use, job['name'] % (network_to_use, var)])



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

