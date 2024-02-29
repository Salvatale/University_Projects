#!/bin/bash

#SBATCH --partition=cpu_guest
#SBATCH --qos=cpu_guest
#SBATCH --output=%x.o%j

#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-30:00:00


echo "#SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"

module load gnu8
gcc factorize0.c -o factorize -lcrypto  -lm

#./factorize -b 32
#./factorize -m F52D204F85FA23653E4B76AD

time ./factorize 20
