import numpy as np

#data_c = np.loadtxt(open("data/fixed_tests/caffenet.txt","rb"), delimiter=",")
#data_cf = np.loadtxt(open("data/caffenet_frozen_102000.txt","rb"), delimiter=",")
#data_cf2 = np.loadtxt(open("data/caffenet_frozen_phase2_55000.txt","rb"), delimiter=",")
#data_cs = np.loadtxt(open("data/caffenet_slowburn_142000.txt","rb"), delimiter=",")
#data_c99g = np.loadtxt(open("data/caffenet_99g_64000.txt","rb"), delimiter=",")
#data_p = np.loadtxt(open("data/places_avg.txt","rb"), delimiter=",")
#data_h = np.loadtxt(open("data/hybrid_avg.txt","rb"), delimiter=",")
data_l = np.loadtxt(open("data/fixed_tests/new_paper.txt","rb"), delimiter=",")


data_100ss = np.loadtxt(open("data/caffenet_100ss_67000.txt","rb"), delimiter=",")
data_200ss = np.loadtxt(open("data/caffenet_200ss_72000.txt","rb"), delimiter=",")
data_300ss = np.loadtxt(open("data/caffenet_300ss_72000.txt","rb"), delimiter=",")
data_400ss = np.loadtxt(open("data/caffenet_400ss_72000.txt","rb"), delimiter=",")
data_500ss = np.loadtxt(open("data/caffenet_500ss_72000.txt","rb"), delimiter=",")
data_600ss = np.loadtxt(open("data/caffenet_600ss_68000.txt","rb"), delimiter=",")
data_1100ss = np.loadtxt(open("data/caffenet_1100ss_64000.txt","rb"), delimiter=",")

print np.average(data_100ss), np.average(data_l)
print np.average(data_200ss), np.average(data_l)
print np.average(data_300ss), np.average(data_l)
print np.average(data_400ss), np.average(data_l)
print np.average(data_500ss), np.average(data_l)
print np.average(data_600ss), np.average(data_l)
print np.average(data_1100ss), np.average(data_l)
