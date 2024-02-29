#!/bin/bash
 
#SBATCH --partition=cpu_guest
#SBATCH --qos=cpu_guest
##SBATCH --nodelist=wn18
#SBATCH --output=%x.o%j 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
##SBATCH --mem=2G
##SBATCH --time=0-00:30:00 
 
echo "#SLURM_JOB_NODELIST: $SLURM_JOB_NODELIST"

DISKTEST=~/HPC2223/perf/disktest/disktest.sh

echo "####################################"
echo "# HOME perf"
cd $HOME
$DISKTEST

cd $SCRATCH
echo "####################################"
echo "# SCRATCH perf"
cd $SCRATCH
$DISKTEST

echo "####################################"

