#/bin/bash

for cam in $(cat "data/cams.txt")
do
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',1); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',5); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',10); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',100); exit" > log.txt < /dev/null &

  echo 'Waiting for' $cam 'to finish'
  wait
done
