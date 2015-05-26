import numpy as np
import matplotlib.pyplot as plt

def main():
  laffont = np.loadtxt(open("data/paper_avg.txt","rb"),delimiter=",")	
  caffenet = np.loadtxt(open("data/caffenet_avg.txt","rb"),delimiter=",") 
  places = np.loadtxt(open("data/places_avg.txt","rb"),delimiter=",") 
  hybrid = np.loadtxt(open("data/hybrid_avg.txt","rb"),delimiter=",") 
  attributes = np.genfromtxt("/scratch/nja224/transient/annotations/attributes.txt", dtype='str')
  
  fig = plt.figure(figsize=(9,4), dpi=200)
  ind = np.arange(len(laffont)) * 3
  width = 0.60

  plt.bar(ind, laffont, width, color='green', align='center', label='Laffont et al.')
  plt.bar(ind + width, caffenet, width, color='blue', align='center', label='Caffenet')
  plt.bar(ind + width * 2, places, width, color='red', align='center', label='Places205-CNN')
  plt.bar(ind + width * 3, hybrid, width, color='yellow', align='center', label='Hybrid-CNN')
  plt.xticks(ind+width*2, attributes, rotation=90)
  plt.ylabel('Average Error')
  plt.legend(loc=1, prop={'size':8})
  plt.axis('tight')
  fig.tight_layout()
  #plt.show()
  plt.savefig('../../paper/deeptransient/figs/avg_err_compare.pdf')

if __name__=="__main__":
	main()
