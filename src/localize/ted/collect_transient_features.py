import glob, numpy, datetime, calendar, h5py

amosDir = '/u/eag-d1/scratch/ted/webcamattri/AMOS_Data/'
featFile = '/u/eag-d1/scratch/ted/webcamattri/AMOS_Data/attributes.csv'

image_list = glob.glob(amosDir + '**/**/*.jpg')


#
# load features
#
feat_dict = {}
with open(featFile, 'r') as f:
  for l in f.readlines():
    cell = l.split(',')
    feat_dict[cell[0]] = numpy.asarray(cell[1:], dtype='float')
    

#
# collect informations
#
names = []
camIds = []
unixHours = []
features = []
for ix, name in enumerate(image_list):

  key = name[-36:]
  if key in feat_dict:
    camIds.append(int(key[:8]))

    timestr = key[-19:-4]
    tm = datetime.datetime.strptime(timestr, '%Y%m%d_%H%M%S')
    unixHours.append(calendar.timegm(tm.timetuple())/60.0/60.0) # utc time zone

    features.append(feat_dict[key])
    names.append(name)


#
# store to h5 file
#
with h5py.File('amos_info.h5') as hf:
  hf['names'] = names
  hf['camIds'] = numpy.asarray(camIds, dtype='int')
  hf['unixHours'] = numpy.asarray(unixHours, dtype='float')
  hf['features'] = numpy.asarray(features, dtype='float')
