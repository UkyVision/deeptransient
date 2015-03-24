import numpy as np

data_c = np.loadtxt(open("data/fixed_tests/caffenet.txt","rb"), delimiter=",")
data_cf = np.loadtxt(open("data/caffenet_frozen_102000.txt","rb"), delimiter=",")
data_cf2 = np.loadtxt(open("data/caffenet_frozen_phase2_55000.txt","rb"), delimiter=",")
data_cs = np.loadtxt(open("data/caffenet_slowburn_142000.txt","rb"), delimiter=",")
#data_p = np.loadtxt(open("data/places_avg.txt","rb"), delimiter=",")
#data_h = np.loadtxt(open("data/hybrid_avg.txt","rb"), delimiter=",")
data_l = np.loadtxt(open("data/fixed_tests/new_paper.txt","rb"), delimiter=",")

#print np.average(data_c), np.average(data_p), np.average(data_h), np.average(data_l)
print np.average(data_c), np.average(data_cf2), np.average(data_l)
