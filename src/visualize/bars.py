import numpy as np
import matplotlib.pyplot as plt
import PIL.Image as Image

truth = np.loadtxt("truth.txt", delimiter="\n")
pred = np.loadtxt("pred.txt", delimiter="\n")
labels = np.loadtxt("attributes.txt", dtype="str", delimiter="\n")

plt.figure(1)

plt.subplot(211)
plt.bar(list(range(pred.size)), pred, color="b")
plt.ylim([0, 1])
plt.xticks([x+0.5 for x in list(range(labels.size))], [])

plt.subplot(212)
plt.bar(list(range(truth.size)), truth, color="r")
plt.ylim([0, 1])
plt.xticks([x+0.5 for x in list(range(labels.size))], labels, rotation='vertical')

plt.tight_layout()
plt.savefig("bars.pdf")
