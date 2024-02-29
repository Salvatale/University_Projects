#!/bin/sh

#!/bin/bash
#SBATCH --output=%x.o%j-all        # Nome del file per lo strandard output
#SBATCH --partition=cpu_guest        # Nome della partizione
#SBATCH --qos=cpu_guest              # Nome della partizione
#SBATCH --nodes=2                    # numero di nodi richiesti
#SBATCH --ntasks-per-node=8          # numero di task MPI per nodo
#SBATCH --cpus-per-task=1            # numero di cpu (openMP) per task
##SBATCH --mem=2G                    # massima memoria utilizzata
#SBATCH --time=0-10:05:00            # massimo tempo di calcolo

echo  "#SLURM_JOB_NODELIST      : $SLURM_JOB_NODELIST"
echo  "#SLURM_JOB_CPUS_PER_NODE : $SLURM_JOB_CPUS_PER_NODE"

module purge
module load intel impi
#module load gnu8 openmpi3

mpicc mpi+omp_heat.c -o mpi+omp_heat -O2 -fopenmp


#DIM=8192
DIM=2048

#mpirun mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null 

OMP_NUM_THREADS=1 mpirun -ppn 8 mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null
OMP_NUM_THREADS=2 mpirun -ppn 4 mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null
OMP_NUM_THREADS=4 mpirun -ppn 2 mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null
OMP_NUM_THREADS=8 mpirun -ppn 1 mpi+omp_heat     -c $DIM -r $DIM   1> /dev/null
