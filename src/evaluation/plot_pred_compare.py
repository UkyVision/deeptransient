import numpy as np
import matplotlib.pyplot as plt

def main():
  laffont = np.loadtxt(open("data/paper_avg.txt","rb"),delimiter=",")	
  caffenet = np.loadtxt(open("data/caffenet_avg.txt","rb"),delimiter=",") 
  attributes = np.genfromtxt("/scratch/nja224/transient/annotations/attributes.txt", dtype='str')
  
  fig1 = plt.figure(figsize=(16,9))
  ax = fig1.add_subplot(111)
  ind = np.arange(len(laffont))
  width = 0.30

  rects1_max = ax.bar(ind, laffont, width, color='green')
  rects2_max = ax.bar(ind + width, caffenet, width, color='blue')
  ax.set_xlim(-width*2, len(ind)+width*2)
  ax.set_xticks(ind + width)
  ax.set_xlabel('Attribute')
  ax.set_ylabel('Average Error')
  ax.set_title('Average Attribute Prediction Error')
  xtickNames = ax.set_xticklabels(attributes)
  plt.setp(xtickNames, rotation=90, fontsize=14)
  ax.legend( (rects1_max[0], rects2_max[0]), ('Laffont et al.', 'Caffenet'))
  #plt.show()
  plt.savefig('../../paper/deeptransient/figs/avg_err_compare_tight.png', dpi=400, bbox_inches='tight')

if __name__=="__main__":
	main()
