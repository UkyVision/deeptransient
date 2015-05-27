#
# use parallel to filter images
#

import glob, os

batchSize = 20

webcamDir = '/u/eag-d1/scratch/ted/deeptransient/AMOS_close/'

PYBIN = os.path.join(os.getcwd(), 'util/remove_bad_images.py')

imgPaths = glob.glob(os.path.join(webcamDir, '**/**/*.jpg'))

# divide image name list into batch chunks
batchNames = [imgPaths[i:i+batchSize] for i in range(0, len(imgPaths), batchSize)]

with open('jobs.txt', 'w') as fid:
  for batch in batchNames:
    fid.write('python {} {}\n'.format(PYBIN, ' '.join(batch)))
    
print 'filtering images...'
os.system('parallel --progress --slf machines.slf -a jobs.txt')
