import os
import glob

cam = '00000260'
files = glob.glob(os.path.join('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/', cam) + '/**/*.jpg')

with open(os.path.join('/u/eag-d1/scratch/ryan/webcams', cam) + '/features/image_names.txt', 'a+') as out:
  for fi in files:
    out.write(fi + '\n')

print 'Done.'
