#!/bin/sh
 
# Richiedi un nodo con una gpu
##SBATCH --partition=gpu_guest
#SBATCH --partition=gpu
#SBATCH --nodes=1 
#SBATCH --mem=4G

#SBATCH --qos=gpu
#SBATCH --gres=gpu:p100:1

# Dichiara che il job durera' al massimo 1 minuto
#SBATCH --time=0-00:01:00

#stampa il nome del nodo assegnato e argomenti                 
echo "#SLURM_JOB_NODELIST   : $SLURM_JOB_NODELIST"
echo "#CUDA_VISIBLE_DEVICES : $CUDA_VISIBLE_DEVICES"

module load cuda/11.6.0

nvcc -O2  heat_gpu_scaling.cu -o heat_gpu_scaling
rm heat_gpu_scaling.txt

for N in 64 128 256 512 1024 2048;
do
	echo -n "$N," >> heat_gpu_scaling.txt
	./heat_gpu_scaling  -c $N -r $N  -s 100000 2>> heat_gpu_scaling.txt
done



