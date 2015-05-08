#/bin/bash

matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','conv1',1); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','pool2',1); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','pool5',1); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','fc8-t',1); exit" > log.txt < /dev/null &

echo 'Waiting for round 1 of 2 to finish'
wait

matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','conv1',100); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','pool2',100); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','pool5',100); exit" > log.txt < /dev/null &
matlab -nodesktop -nosplash -r "make_average_images('transientneth','transientneth','fc8-t',100); exit" > log.txt < /dev/null &

echo 'Waiting for round 2 of 2 to finish'
wait
