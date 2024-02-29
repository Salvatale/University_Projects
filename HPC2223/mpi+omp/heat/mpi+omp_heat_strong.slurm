#!/bin/sh

#!/bin/bash
#SBATCH --output=%x.o%j  # Nome del file per lo strandard output
#SBATCH --partition=cpu_guest        # Nome della partizione
#SBATCH --qos=cpu_guest              # Nome della partizione
#SBATCH --nodes=2                    # numero di nodi richiesti
#SBATCH --ntasks-per-node=8          # numero di cpu per nodo
##SBATCH --mem=2G                    # massima memoria utilizzata
#SBATCH --time=0-10:05:00            # massimo tempo di calcolo

echo  "#SLURM_JOB_NODELIST      : $SLURM_JOB_NODELIST"
echo  "#SLURM_JOB_CPUS_PER_NODE : $SLURM_JOB_CPUS_PER_NODE"

module purge
module load intel impi
#module load gnu8 openmpi3

icc    heat.c         -o heat         -O2
icc    omp_heat.c     -o omp_heat     -O2 -fopenmp
mpiicc mpi_heat.c     -o mpi_heat     -O2 
mpiicc mpi+omp_heat.c -o mpi+omp_heat -O2 -fopenmp

rm -f heat_strong.dat  omp_heat_strong.dat mpi_heat_strong.dat  mpi+omp_heat_strong.dat 

#DIM=8192
DIM=2048

./heat -c $DIM -r $DIM       1> /dev/null  2>>heat_strong.dat


for T in 1 2 4 8
do
OMP_NUM_THREADS=$T                   omp_heat     -c $DIM -r $DIM   1> /dev/null  2>>omp_heat_strong.dat
                   mpirun -np $T     mpi_heat     -c $DIM -r $DIM   1> /dev/null  2>>mpi_heat_strong.dat
OMP_NUM_THREADS=$T mpirun -ppn 1 mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null  2>>mpi+omp_heat_strong.dat
done
