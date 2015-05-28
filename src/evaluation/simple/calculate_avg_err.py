import numpy as np

data_cnn = np.loadtxt(open("data/siamese_err.txt","rb"), delimiter=" ")
data_deeptransient = np.loadtxt(open("data/deeptransient_err.txt","rb"), delimiter=" ")

print 'Siamese MSE: {}'.format(data_cnn.mean())
print 'deeptransient MSE: {}'.format(data_deeptransient.mean())
