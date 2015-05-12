#/bin/bash

for cam in $(cat "cams.txt")
do
  echo $cam
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',1); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',5); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',10); exit" > log.txt < /dev/null &
  matlab -nodesktop -nosplash -r "make_average_images('$cam','transientneth','fc8-t',10); exit" > log.txt < /dev/null &

  echo 'Waiting for round 1 of 2 to finish'
  wait
done
