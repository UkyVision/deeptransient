import glob
import numpy as np
import matplotlib.pyplot as plt 

slurms = glob.glob('experiments/twoclass/finetune_connor/*.out')

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

print np.shape(iteration)
print np.shape(loss)

plt.plot(iteration, loss)
plt.show()

for iter,loss,slurm in min_loss_stacked:
  print slurm, iter, loss
