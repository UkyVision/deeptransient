#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --partition=GPU

source ~rmba229/projects/caffe/setup_paths.sh

srun start_training.sh
#srun retrain.sh

