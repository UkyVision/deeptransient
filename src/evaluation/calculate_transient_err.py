import numpy as np

data_c = np.loadtxt(open("data/new_stuff.txt","rb"), delimiter=",")
#data_c = np.loadtxt(open("data/caffenet_avg.txt","rb"), delimiter=",")
#data_p = np.loadtxt(open("data/places_avg.txt","rb"), delimiter=",")
#data_h = np.loadtxt(open("data/hybrid_avg.txt","rb"), delimiter=",")
data_l = np.loadtxt(open("data/new_paper.txt","rb"), delimiter=",")

#print np.average(data_c), np.average(data_p), np.average(data_h), np.average(data_l)
print np.average(data_c), np.average(data_l)
