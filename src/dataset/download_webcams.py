#
# download webcam list
#

import os
import scipy.io as io

pwd = os.getcwd()

data = io.loadmat('webcam_list.mat')
with open('jobs.txt', 'w') as fid:
	for camid, time in zip(data['AMOScamIds'], data['yyyy_mm']):
		fid.write('python {} single {} {}\n'.format(os.path.join(pwd, 'util/download_amos.py'), camid[0],  str(time[0][0])))

		
print 'downloading images...'
os.system('parallel --progress --slf machines.slf -a jobs.txt')
