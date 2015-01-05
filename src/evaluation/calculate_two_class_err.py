import numpy as np

net = 'caffenet'

sunny = np.loadtxt(open("data/sunny_" + net + ".txt","rb"), delimiter="\n")
cloudy = np.loadtxt(open("data/cloudy_" + net + ".txt","rb"), delimiter="\n")

correct_sunny = np.size(sunny) - np.count_nonzero(sunny)
correct_cloudy = np.count_nonzero(cloudy)

print  float(correct_sunny + correct_cloudy) / (np.size(sunny) + np.size(cloudy))
