import numpy as np
from pylab import *

def foobar(error_file):
  errors = []

  with open(error_file) as file:
    for line in file:
      errors.append(float(line.strip()))

  errors = np.sort(errors)
  Y = np.array([sum(errors <= low) for low in np.arange(0, 0.28, 0.01)])
  Y1 = np.divide(Y,len(errors), dtype=np.float64)
 
  return Y1

if __name__ == '__main__':
  caffenet, = plot(foobar('errors/caffenet.txt'), label='caffenet_finetune')
  caffenet_scratch, = plot(foobar('errors/caffenet_scratch.txt'), label='caffenet_scratch')
  random_guess, = plot(foobar('errors/random_guess.txt'), label='random_guess')
  laffont, = plot(foobar('errors/paperdata.txt'), label='laffont et al.')
  places, = plot(foobar('errors/places.txt'), label='places')
  hybrid, = plot(foobar('errors/hybrid.txt'), label='hybrid')
  #simplenet, = plot(foobar('errors/simplenet.txt'), label='simplenet')
  #bignet, = plot(foobar('errors/bignet.txt'), label='bignet')
  ylabel("Percentage of Test Images Correct")
  xlabel("Error in Predictions (%)")
  legend(loc=4)
  show()
