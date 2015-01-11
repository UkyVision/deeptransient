import re
import os.path

from PIL import Image
import numpy as np

from matplotlib import rc
rc('font',**{'family':'serif','serif':['Computer Modern Roman']})
rc('text', usetex=True)

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

PLOT = True
SAVEFIG = True

images_dir = "/u/eag-d1/data/transient/transient/imageAlignedLD"
results_file_name = "pred_caffenet_transient.txt"
attributes_file_name = "attributes.txt"

# build attributes list
attributes = []
with open(attributes_file_name) as f:
    for line in f:
        attributes.append(line.strip())

with open(results_file_name) as f:
    for line in f:
        (fname, raw_scores) = line.split(" ", 1)
        scores = map(float, re.split(" +", re.sub("\[|\]", "",
            raw_scores).strip()))
       
        top = [attributes[x] for x in np.argsort(scores)[-3:][::-1]]
        bottom = [attributes[x] for x in np.argsort(scores)[:3][::-1]]

        im = Image.open(os.path.join(images_dir, fname))
        cells = np.vstack([top,bottom]).T
        
        print fname

        if PLOT:
            # plotting
            gs = gridspec.GridSpec(1, 2, width_ratios=[1, 2])
            
            plt.figure(1)

            plt.subplot(gs[0])
            plt.imshow(im)
            plt.gca().axis("off")

            plt.subplot(gs[1])
            plt.table(cellText=cells,colLabels=("is", "is not"),loc="center")
            plt.gca().axis("off")

            plt.tight_layout()

            if SAVEFIG:
                plt.gcf().set_size_inches(15, 7, bbox_inches="tight")
                plt.savefig(os.path.join("is_isnt", fname.replace("/","_")))
            else:
                plt.show()
        else:
            template = '''
                \\begin{subfigure}
                    \centering
                    %s
                \end{subfigure}
            '''
            plot_template = '''
                \includegraphics{%s}
                \\begin{table}{| c | c |}
                    \hline
                    is & isnt \\\\
                    \hline
                    %s & %s \\\\
                    %s & %s \\\\
                    %s & %s \\\\
                    \hline
                \end{table}
            '''
            plot = plot_template % ((fname,) + tuple(cells.flatten()))
            print template % plot
