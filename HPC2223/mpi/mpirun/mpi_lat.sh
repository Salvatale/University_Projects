#!/bin/bash

echo " ###################### GNU "
module purge
module load gnu8 openmpi3 

 mpicc mpi_latency.c   -o mpi_latency
echo gnu8 OPA
$(which mpirun)  --hostfile hostfile.txt  -np 2  -npernode 1    hostname
$(which mpirun)  --hostfile hostfile.txt  -np 2  -npernode 1    mpi_latency  | grep Avg 
echo gnu8 SHM
$(which mpirun)  --hostfile hostfile.txt  -np 2  -npernode 2    hostname
$(which mpirun)  --hostfile hostfile.txt  -np 2  -npernode 2    mpi_latency  | grep Avg


echo " ###################### INTEL "
module purge
module load intel impi    


mpicc mpi_latency.c   -o mpi_latency
echo intel  mpicc OPA
mpirun  --machine machine.txt  -np 2  -ppn 1    hostname
mpirun  --machine machine.txt  -np 2  -ppn 1    mpi_latency | grep Avg
echo intel  mpicc SHM
mpirun  --machine machine.txt  -np 2  -ppn 2    hostname
mpirun  --machine machine.txt  -np 2  -ppn 2    mpi_latency | grep Avg

mpiicc mpi_latency.c   -o mpi_latency
echo intel  mpiicc OPA
mpirun  --machine machine.txt  -np 2  -ppn 1    hostname
mpirun  --machine machine.txt  -np 2  -ppn 1    mpi_latency | grep Avg
echo intel  mpiicc SHM
mpirun  --machine machine.txt  -np 2  -ppn 2    hostname
mpirun  --machine machine.txt  -np 2  -ppn 2    mpi_latency | grep Avg


