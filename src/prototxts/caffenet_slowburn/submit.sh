#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --partition=GPU

source ~/projects/caffe/setup_paths.sh

#srun start_training.sh
srun retrain.sh

