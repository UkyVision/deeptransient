import glob
import numpy as np

slurms = glob.glob('jobs/**/*.out')

min_loss = []
min_loss_iter = []
for slurm in slurms:
  loss = []
  iteration = []
  with open(slurm, 'r') as f:
    for line in f:
      if 'Testing net' in line:
        iteration.append(line.split()[5][:-1])
      if 'Test net output' in line:
        loss.append(line.split()[10])

    min_loss.append(min(loss))
    min_loss_iter.append(iteration[loss.index(min(loss))])

slurms = np.vstack(slurms)
min_loss = np.vstack(min_loss)
min_loss_iter = np.vstack(min_loss_iter)
min_loss_stacked = np.hstack([min_loss_iter, min_loss, slurms])

for iter,loss,slurm in min_loss_stacked:
  print slurm, iter, loss
