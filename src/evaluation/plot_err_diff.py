import numpy as np
import matplotlib.pyplot as plt

def main():
  laffont = np.loadtxt(open("data/paper_avg.txt","rb"),delimiter=",")	
  caffenet = np.loadtxt(open("data/caffenet_avg.txt","rb"),delimiter=",") 
  attributes = np.genfromtxt("/scratch/nja224/transient/annotations/attributes.txt", dtype='str')
  
  difference = caffenet - laffont
  labeled = np.concatenate((difference[:].reshape(40,1), attributes[:].reshape(40,1)), axis=1)
  labeled = labeled[labeled[:,0].astype(float).argsort()]

  fig1 = plt.figure(figsize=(14,9))
  ax = fig1.add_subplot(111)
  ind = np.arange(len(labeled[:,0]))
  width = 0.50

  rects1_max = ax.bar(ind, labeled[:,0].astype(float), width, color='blue')
  ax.set_xlim(-width*2, len(ind)+width*2)
  ax.set_xticks(ind + width)
  ax.set_xlabel('Attribute')
  ax.set_ylabel('Average Error')
  ax.set_title('Average Attribute Prediction Error')
  xtickNames = ax.set_xticklabels(labeled[:,1])
  plt.setp(xtickNames, rotation=90, fontsize=14)
  #plt.show()
  plt.savefig('../../paper/deeptransient/figs/rel_err_tight.png', dpi=400, bbox_inches='tight')

if __name__=="__main__":
	main()
