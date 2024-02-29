#!/bin/bash

#SBATCH --partition=cpu_guest
#SBATCH --qos=cpu_guest
#SBATCH --output=%x.o%j

#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-23:05:00


echo "#SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"
gcc -fopenmp omp_factorize.c -o factorize -lcrypto  -lm

for T in 1 2 4 8
do
	./omp_factorize -t $T -m B686C5D7A74B840E8B27F840126367F5
	./omp_factorize -t $T -m D41EEDCA71F14147E3F7A1FD
	./omp_factorize -t $T -m B7D4AA3A02A2CA4D
done
