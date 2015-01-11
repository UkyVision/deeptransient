import re
import os.path

from PIL import Image
import numpy as np

from matplotlib import rc
rc('font',**{'family':'serif','serif':['Computer Modern Roman']})
rc('text', usetex=True)

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

SAVEFIG = True

images_dir = "/u/eag-d1/data/transient/transient/imageAlignedLD"
results_file_name = "pred_caffenet_transient.txt"
attributes_file_name = "attributes.txt"

# build attributes list
attributes = []
with open(attributes_file_name) as f:
    for line in f:
        attributes.append(line.strip())

scores = dict()
with open(results_file_name) as f:
    for line in f:
        (fname, raw_scores) = line.split(" ", 1)
        scores[fname] = map(float, re.split(" +", re.sub("\[|\]", "",
            raw_scores).strip()))
       
#fnames = scores.keys()[:3]
fnames = ["00000090/123.jpg", "00017659/20120214_142344.jpg",
"00019919/20120713_055225.jpg"]
# plotting
gs = gridspec.GridSpec(3, 2, width_ratios=[1,2])
plt.figure(1)

# image 1
fname = fnames[0]
score = scores[fname]

plt.subplot(gs[0])
im = Image.open(os.path.join(images_dir, fname))
plt.imshow(im)
plt.gca().axis("off")

plt.subplot(gs[1])
plt.bar(list(range(len(score))), score, color="b")
plt.ylim([0, 1])
plt.xticks([x+0.5 for x in list(range(len(attributes)))],
        [], rotation='vertical')

# image 2
fname = fnames[1]
score = scores[fname]

plt.subplot(gs[2])
im = Image.open(os.path.join(images_dir, fname))
plt.imshow(im)
plt.gca().axis("off")

plt.subplot(gs[3])
plt.bar(list(range(len(score))), score, color="b")
plt.ylim([0, 1])
plt.xticks([x+0.5 for x in list(range(len(attributes)))],
        [], rotation='vertical')

# image 3
fname = fnames[2]
score = scores[fname]

plt.subplot(gs[4])
im = Image.open(os.path.join(images_dir, fname))
plt.imshow(im)
plt.gca().axis("off")

plt.subplot(gs[5])
plt.bar(list(range(len(score))), score, color="b")
plt.ylim([0, 1])
plt.xticks([x+0.5 for x in list(range(len(attributes)))],
        attributes, rotation='vertical')


plt.tight_layout()

if SAVEFIG:
    plt.gcf().set_size_inches(12, 9)
    plt.savefig(os.path.join("bars.pdf"),
            bbox_inches="tight")
else:
    plt.show()
