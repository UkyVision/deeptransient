import numpy as np

net = 'caffenet'

data = np.loadtxt(open("data/two_class_" + net + ".txt","rb"), delimiter="\n")

correct_pred = np.count_nonzero(data)

acc = float(correct_pred) / np.size(data)

norm_acc = max((acc - 0.5) / (1 - 0.5), 0)

print acc, norm_acc
