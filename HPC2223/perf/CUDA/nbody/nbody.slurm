#!/bin/bash

#BATCH --output=%x.o%j-P100  # Nome del file per lo strandard output
##SBATCH --error=%x.e%j       # Se non specificato stderr e' rediretto su stdout 
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:p100:1
#SBATCH --time=0-00:10:00
#SBATCH --mem=4G
 
module load gnu/5.4.0   cuda/11.5.2
 
echo "#SLURM_JOB_NODELIST   : $SLURM_JOB_NODELIST"
echo "#CUDA_VISIBLE_DEVICES : $CUDA_VISIBLE_DEVICES"

cp  ${CUDA_HOME}/samples/5_Simulations/nbody/* .
sed -i 's/\/usr\/local\/cuda/$(CUDA_HOME)/g'  Makefile
sed -i 's/..\/..\/common\/inc/$(CUDA_PATH)\/samples\/common\/inc/g' Makefile
  
make

./nbody -benchmark -fp64 -numbodies=1024000 -numdevices=1
