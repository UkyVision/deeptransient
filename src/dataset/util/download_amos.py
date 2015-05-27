# download_amos.py
# Austin Abrams, 2/16/10
# Scott Workman, 9/25/14
# a helper utility to download and unzip a lot of images from the AMOS dataset.

import os
import sys
import urllib2
import StringIO
import zipfile
import threading
import time
import argparse

import dateutil.parser
import dateutil.relativedelta

# Change this to where you want data to be dumped off.  If not supplied, defaults to
# the current working directory.
# ROOT_LOCATION = os.getcwd() + '/AMOS_Data'
ROOT_LOCATION = '/u/eag-d1/scratch/ted/deeptransient/AMOS_close'

# if the script crashed or the power went out or something, this flag will
# skip downloading and unzipping a month's worth of images if there's already
# a folder where it should be.  If you set this to false, then downloads
# will overwrite any existing files in case of filename conflict.
SKIP_ALREADY_DOWNLOADED = True

# maximum number of threads allowed. This can be changed.
MAX_THREADS = 100

class DownloadThread(threading.Thread):
	camera_id = None
	year = None
	month = None

	def __init__(self, camera_id, year, month):
		threading.Thread.__init__(self)

		self.camera_id = camera_id
		self.year = year
		self.month = month

	def run(self):
		location = ROOT_LOCATION + '%08d/%04d.%02d/' % (self.camera_id, self.year, self.month)

		if SKIP_ALREADY_DOWNLOADED and os.path.exists(location):
			print(location + " already downloaded.")
			return

		print("downloading to " + location)
		zf = download(self.camera_id, self.month, self.year)
		print("completed downloading to " + location)

		if not zf:
			print("skipping " + location)
			return

		ensure_directory_exists(location)

		print("Extracting from " + location)
		extract(zf, location)
		print("Done")


def download(camera_id, month, year):
  """
  Downloads a zip file from AMOS, returns a file.
  """
  last_two_digits = camera_id % 100;
  last_four_digits = camera_id % 10000;
    
  if year < 2013 or year == 2013 and month < 9:
    ZIPFILE_URL = 'http://amosweb.cse.wustl.edu/2012zipfiles/'
  else :
    ZIPFILE_URL = 'http://amosweb.cse.wustl.edu/zipfiles/'
    
  url = ZIPFILE_URL + '%04d/%02d/%04d/%08d/%04d.%02d.zip' % (year, last_two_digits, last_four_digits, camera_id, year, month)
  #print '    downloading...',
  sys.stdout.flush()
    
  try:
    result = urllib2.urlopen(url)
  except urllib2.HTTPError as e:
    print e.code, 'error.'
    return None
        
  handle = StringIO.StringIO(result.read())
    
  #print 'done.'
  sys.stdout.flush()
    
  return handle
    
def extract(file_obj, location):
  """
  Extracts a bunch of images from a zip file.
  """
  #print '    extracting zip...',
  sys.stdout.flush()
    
  zf = zipfile.ZipFile(file_obj, 'r')
  zf.extractall(location)
  zf.close()
  file_obj.close()
    
  #print 'done.'
  sys.stdout.flush()
    
def ensure_directory_exists(path):
  """
  Makes a directory, if it doesn't already exist.
  """
  dir_path = path.rstrip('/')       
 
  if not os.path.exists(dir_path):
    parent_dir_path = os.path.dirname(dir_path)
    ensure_directory_exists(parent_dir_path)

    try:
      os.mkdir(dir_path)
    except OSError:
      pass
	
def date_range(start_date, end_date):
  """
  Generates a list of dates (by month) between start_date and
  end_date. 
  """
  dates = []
  current_date = start_date
  while current_date <= end_date:
    dates.append(current_date)
    current_date = current_date + dateutil.relativedelta.relativedelta(months=1)
 
  return dates

def download_parallel(camera_id, dates):
  """
  Launches parallel download threads.
  """
  for date in dates:
    thread_count = threading.activeCount()
    while thread_count > MAX_THREADS:
      print("Waiting for threads to finish...")
      time.sleep(1)
      thread_count = threading.activeCount()              

    download_thread = DownloadThread(camera_id=camera_id, year=date.year, month=date.month)
    download_thread.start()


def main(args):

  if args.command == "single":
    camera_id = args.camera_id
    dates = [dateutil.parser.parse(args.date)]
  elif args.command == "range":
    camera_id = args.camera_id
    start_date = dateutil.parser.parse(args.start_date).date().replace(day=1)
    end_date = dateutil.parser.parse(args.end_date).date().replace(day=1)
    dates = date_range(start_date, end_date)
  elif args.command == "file":
    print args.file.read()
    sys.exit('Not yet implemented')
  
  download_parallel(camera_id, dates)


if __name__ == '__main__':
  
  description = 'Download images for a camera from AMOS.'
  usage = {'single': 'python download_amos.py single 90 2014-08',
      'range': 'python download_amos.py range 90 2014-08 2014-09',
      'file': 'python download_amos.py file (stdin or file)'}

  parser = argparse.ArgumentParser(description=description, formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument('-o', type=str, help='output directory')
  subparsers = parser.add_subparsers(dest='command')
  
  parser_single = subparsers.add_parser('single', usage=usage['single'])
  parser_single.add_argument('camera_id', type=int)
  parser_single.add_argument('date', type=str)
  
  parser_range = subparsers.add_parser('range', usage=usage['range'])
  parser_range.add_argument('camera_id', type=int)
  parser_range.add_argument('start_date', type=str)
  parser_range.add_argument('end_date', type=str)
  
  parser_file = subparsers.add_parser('file', usage=usage['file'])
  parser_file.add_argument('file', nargs='?', type=argparse.FileType('r'), default=sys.stdin)

  args = parser.parse_args()

  if args.o is not None:
    ROOT_LOCATION = args.o
 
  if ROOT_LOCATION[-1] != '/':
    ROOT_LOCATION = ROOT_LOCATION + '/'

  main(args)
