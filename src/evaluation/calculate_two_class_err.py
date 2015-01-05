import numpy as np

net = 'caffenet'

sunny = np.loadtxt(open("data/sunny_" + net + ".txt","rb"), delimiter="\n")
cloudy = np.loadtxt(open("data/cloudy_" + net + ".txt","rb"), delimiter="\n")

for ix in xrange(0,5):
  np.random.shuffle(sunny)
  np.random.shuffle(cloudy)

  test_sunny = sunny[0:(np.size(sunny)*0.2)]
  test_cloudy = cloudy[0:np.size(cloudy)*0.2]

  correct_sunny = np.size(test_sunny) - np.count_nonzero(test_sunny)
  correct_cloudy = np.count_nonzero(test_cloudy)
  
  a = float(correct_sunny + correct_cloudy) / (np.size(test_sunny) + np.size(test_cloudy))
  
  norm_error = max((a - 0.5) / (1 - 0.5), 0)

  print norm_error
