import sys, os

if len(sys.argv) < 2:
  targetDir = './'
else:
  targetDir = sys.argv[1]

#%%
items = [os.walk(targetDir).next()][0]
snapshots = {}
for name in items[2]:
  if name.lower().find('snapshot') == 0:
    iters = int(name.split('_')[-1].split('.')[0])
    snapshots[name] = iters
    
    
# find the most recent snapshots
recentSnapshots = []
maxIters = 0
for ix, name in enumerate(snapshots):
  if snapshots[name] > maxIters:
    recentSnapshots = [name]
    maxIters = snapshots[name]
  elif snapshots[name] == maxIters:
    recentSnapshots.append(name)
    
# delete old snapshots
for name in snapshots:
  path = os.path.join(targetDir, name)
  if name not in recentSnapshots:
    os.remove(path)
    print 'remve old snapshot: {}'.format(path)
