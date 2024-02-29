#!/bin/sh
 
# Richiedi un nodo con una gpu
##SBATCH --partition=gpu_guest
#SBATCH --partition=gpu
#SBATCH --nodes=1 
#SBATCH --mem=4G

#SBATCH --qos=gpu
#SBATCH --gres=gpu:p100:1

# Dichiara che il job durera' al massimo 1 minuto
#SBATCH --time=0-00:10:00

#stampa il nome del nodo assegnato e argomenti                 
echo "#SLURM_JOB_NODELIST   : $SLURM_JOB_NODELIST"
echo "#CUDA_VISIBLE_DEVICES : $CUDA_VISIBLE_DEVICES"

module load cuda/11.6.0


for B in 4 8 16 32;do

	cp heat_gpu_block_scaling.cu temp.cu
	sed -i "s/SIZE/$B/g" temp.cu
	nvcc -O2  temp.cu -o temp
	rm heat_gpu_scaling$B.txt
	rm temp.cu

	for N in 64 128 256 512 1024 2048;
	do
		echo -n "$N," >> heat_gpu_scaling$B.txt
		./temp  -c $N -r $N  -s 100000 2>> heat_gpu_scaling$B.txt
	done
done



