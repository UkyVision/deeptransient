import numpy as np
import matplotlib.pyplot as plt

def main():
  laffont = np.loadtxt(open("data/paper_avg.txt","rb"),delimiter=",")	
  places = np.loadtxt(open("data/places_avg.txt","rb"),delimiter=",")	
  hybrid = np.loadtxt(open("data/hybrid_avg.txt","rb"),delimiter=",")	
  caffenet = np.loadtxt(open("data/caffenet_avg.txt","rb"),delimiter=",") 
  attributes = np.genfromtxt("/scratch/nja224/transient/annotations/attributes.txt", dtype='str')
  
  difference = caffenet - places
  labeled = np.concatenate((difference[:].reshape(40,1), attributes[:].reshape(40,1)), axis=1)
  labeled = labeled[labeled[:,0].astype(float).argsort()]

  ind = np.arange(len(labeled[:,0]))

  fig = plt.figure(figsize=(8,8), dpi=200) 
  plt.barh(ind, labeled[:,0].astype(float), align='center', color='blue')
  plt.yticks(ind, labeled[:,1])
  plt.xlabel('Average Error')
  plt.axis('tight')
  #plt.show()
  fig.tight_layout()
  fig.savefig('../../paper/deeptransient/figs/rel_err_places.pdf')

if __name__=="__main__":
	main()
