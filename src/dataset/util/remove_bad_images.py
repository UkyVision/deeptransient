#
# filter bad images (i.e. black screen, blue screen)
#

from matplotlib import pyplot as plt
import random, sys, os

if len(sys.argv) < 2:
  print 'Usage: {} image_path1 image_path2 ...'.format(sys.argv[0])
  quit()
  
img_path = sys.argv[1]

# threshold for the mean value of each channel, lower than this threshold
# could possibly be a blank screen
channel_min = 30
channel_max = 200

for img_path in sys.argv[1:]:

  try:
    im = plt.imread(img_path)
  except:
    print "bad image {}".format(img_path)
    os.remove(img_path)
    continue

  # check for blank screen
  r_mean = im[:,:,0].mean()
  g_mean = im[:,:,1].mean()
  b_mean = im[:,:,2].mean()
  v_mean = sum([r_mean, g_mean, b_mean]) / 3.0

  if (r_mean < channel_min and g_mean < channel_min and b_mean > channel_max) or \
     (r_mean > channel_max and g_mean < channel_min and b_mean < channel_min) or \
     (r_mean < channel_min and g_mean > channel_max and b_mean < channel_min) or \
     v_mean < channel_min or v_mean > channel_max:
    print "blank image {}".format(img_path)
    os.remove(img_path)

