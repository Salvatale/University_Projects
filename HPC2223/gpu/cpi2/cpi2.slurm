#!/bin/sh

# Richiedi un nodo con una gpu
#SBATCH --output=%x.o%j
#SBATCH --partition=gpu
#SBATCH --nodes=1 
#SBATCH --mem=2G

#SBATCH --qos=gpu
#SBATCH --gres=gpu:p100:1

# Dichiara che il job durera' al massimo 1 minuto
#SBATCH --time=0-00:10:00

#stampa il nome del nodo assegnato e argomenti                 
echo "#SLURM_JOB_NODELIST   : $SLURM_JOB_NODELIST"
echo "#CUDA_VISIBLE_DEVICES : $CUDA_VISIBLE_DEVICES"

#esegui il programma
module load cuda 
nvcc -arch=sm_60 cpi2.cu
rm cpi2_scaling.dat

for B in 128 256 512 1024 2048 4096
do
./a.out $B 2>> cpi2_scaling.dat
done
