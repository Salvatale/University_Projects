#!/bin/bash
#SBATCH --output=%x.o%j
##SBATCH --error=%x.e%j
#SBATCH --partition=cpu_guest
#SBATCH --qos=cpu_guest
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00-23:00:00

echo "#SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"

echo "Thread,Nx,Ny,iter,T,Tp,Tnp" > omp_heat_gnu4.dat
echo "Thread,Nx,Ny,iter,T,Tp,Tnp" > omp_heat_gnu8.dat
echo "Thread,Nx,Ny,iter,T,Tp,Tnp" > omp_heat_intel.dat


##GNU4

module purge
gcc -fopenmp -O3 omp_heat.c -o omp_heat_gnu4

for T in 1 2 4 8
do
	echo -n "$T," >> omp_heat_gnu4.dat
	OMP_NUM_THREADS=$T ./omp_heat_gnu4 -r 2048 -c 2048 1> /dev/null 2>> omp_heat_gnu4.dat
done

##GNU8

module purge
module load gnu8

gcc -fopenmp -O3 omp_heat.c -o omp_heat_gnu8

for T in 1 2 4 8
do
        echo -n "$T," >> omp_heat_gnu8.dat
        OMP_NUM_THREADS=$T ./omp_heat_gnu8 -r 2048 -c 2048 1> /dev/null 2>> omp_heat_gnu8.dat
done

##Intel

module purge
module load intel openmpi/2.1.2

icc -qopenmp -O3 omp_heat.c -o omp_heat_intel

for T in 1 2 4 8
do
        echo -n "$T," >> omp_heat_intel.dat
        OMP_NUM_THREADS=$T ./omp_heat_intel -r 2048 -c 2048 1> /dev/null 2>> omp_heat_intel.dat
done

module purge

python2 omp_heat_scaling_plot.py
