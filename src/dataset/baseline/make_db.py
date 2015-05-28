#
# make lmdb database for baseline method (without siamese pairs).
# images from close AMOS webcam share the same labels with their
# counterparts from transient dataset
#
import os, re, caffe, lmdb, shutil
import numpy as np


amosImageDir = '/u/eag-d1/scratch/ted/deeptransient/AMOS_close/'
transientDir = '/u/eag-d1/data/transient/transient/imageAlignedLD/'
image_label_file = '/u/eag-d1/scratch/ted/webcamattri/transient/annotations.csv'

# location to store train/val database
db_location = '/u/eag-d1/scratch/ted/deeptransient/lmdbs/baseline/'
if not os.path.isdir(db_location):
  os.mkdir(db_location)

image_size = 256

transientNames = [
  'dirty','daylight','night','sunrisesunset','dawndusk',
  'sunny','clouds','fog','storm','snow',
  'warm','cold','busy','beautiful','flowers',
  'spring','summer','autumn','winter','glowing',
  'colorful','dull','rugged','midday','dark',
  'bright','dry','moist','windy','rain','ice',
  'cluttered','soothing','stressful','exciting',
  'sentimental','mysterious','boring','gloomy','lush'
]
transient2colnum = { name:(2*ix+1) for ix, name in enumerate(transientNames)}

interest_transients = transientNames


# load transient dataset labels
transientLabels = {}
with open(image_label_file, 'r') as f:
  for line in f.readlines():
    cell = re.split('\t|,', line)
    label = [ float(cell[transient2colnum[key]].strip()) for key in transientNames ]
    interest_label = [ float(cell[transient2colnum[key]].strip()) for key in interest_transients ]
    name = transientDir + cell[0].strip()
    transientLabels[name] = {'full':label, 'interest':interest_label}
    
def parse_pairs_txt(pairs_txt):
  pairs = []
  with open(pairs_txt, 'r') as f:
    for line in f.readlines():
      cell = line.split(' ')
      unit = [cell[0].strip(), cell[1].strip(), int(cell[2].strip())]
      pairs.append(unit)
      
  return pairs


def generate_db_list(pairs):

  db_list = {}
  for pair in pairs:
    imgName0 = pair[0]
    imgName1 = pair[1]
    siaLabel = pair[2]

    tranLabel = transientLabels[imgName0]

    db_list[imgName0] = tranLabel
    
    if siaLabel == 1: # positive pair use the same label
      db_list[imgName1] = tranLabel

  return db_list


def chunk(s, n):
  assert n > 0
  while len(s) >= n:
    yield s[:n]
    s = s[n:]
  if len(s):
    yield s


def make_database(pairs_txt, mode):

  dbDir = os.path.join(db_location, mode)

  if mode == 'debug' and os.path.isdir(dbDir): # debug mode
    shutil.rmtree(dbDir)

  if os.path.isdir(dbDir):
    raise Exception(dbDir + ' already exists. Delete it')

  os.mkdir(dbDir)

  # initiate lmdb env
  im_db = lmdb.Environment(dbDir + '/image_db', map_size=1000000000000)
  lb_db = lmdb.Environment(dbDir + '/label_db', map_size=1000000000000)
  
  pairs = parse_pairs_txt(pairs_txt)
  db_list = generate_db_list(pairs)

  with im_db.begin(write=True) as im_db_txn:
    with lb_db.begin(write=True) as lb_db_txn:

      for key, imgName in enumerate(db_list):

        label = db_list[imgName]
        allLabel = np.asarray(label['full'])
        traLabel = np.asarray(label['interest'])

        # load image
        try:
          img = caffe.io.load_image(imgName)
        except:
          print 'bad image, skip it.'
          continue

        # resizing
        img = caffe.io.resize_image(img, (image_size, image_size))

        # channel swap for pre-trained (RGB -> BGR)
        img = img[:, :, [2,1,0]]

        # make channels x height x width
        img = img.swapaxes(0,2).swapaxes(1,2)

        # convert to uint8
        img = (255*img).astype(np.uint8, copy=False) 

        # image array to datum 
        img_datum = caffe.io.array_to_datum(img)
        img_datum.ClearField('label')
        img_str = img_datum.SerializeToString()


        # transient labels to datum
        traLabel = traLabel.reshape((len(traLabel), 1, 1)) # reshaping to caffe format
        tra_datum = caffe.io.array_to_datum(traLabel)
        tra_datum.ClearField('label')
        tra_str = tra_datum.SerializeToString()
          

        #
        # write datum to lmdb
        #
        key_str = str(key)
        im_db_txn.put(key_str, img_str)
        lb_db_txn.put(key_str, tra_str)

        if key % 1000 == 0:
          print "processed %d of %d images (%s)" % (key, len(db_list), mode)


make_database('../siamese_pairs/debug_pairs.txt', 'debug')
make_database('../siamese_pairs/train_pairs.txt', 'train')
make_database('../siamese_pairs/val_pairs.txt', 'val')