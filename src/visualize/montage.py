import re
import os.path

from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

PLOT = False
SAVEFIG = False

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
        
        if PLOT:
            # plotting
            plt.figure(1)

            plt.subplot(121)
            plt.imshow(im)
            plt.gca().axis("off")

            plt.subplot(122)
            plt.table(cellText=cells,colLabels=("is", "is not"),loc="center")
            plt.gca().axis("off")

            plt.tight_layout()

            if SAVEFIG:
                plt.savefig()
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
