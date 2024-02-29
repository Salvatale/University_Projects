#!/usr/bin/env python2

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd

heat4 = pd.read_csv("heat_gpu_scaling4.txt",sep=',', names=["matrixSize","time"])
heat8 = pd.read_csv("heat_gpu_scaling8.txt",sep=',', names=["matrixSize","time"])
heat16 = pd.read_csv("heat_gpu_scaling16.txt",sep=',', names=["matrixSize","time"])
heat32 = pd.read_csv("heat_gpu_scaling32.txt",sep=',', names=["matrixSize","time"])


plt.title('Heat_gpu scaling')
plt.grid()
plt.xlabel('Dimensione matrice')
plt.ylabel('Tempo')
plt.plot(heat4.matrixSize,heat4.time,'b-o', label='BLOCK_SIZE=4')
plt.plot(heat8.matrixSize,heat8.time,'y-o', label='BLOCK_SIZE=8')
plt.plot(heat16.matrixSize,heat16.time,'r-o', label='BLOCK_SIZE=16')
plt.plot(heat32.matrixSize,heat32.time,'g-o', label='BLOCK_SIZE=32')

plt.legend(shadow=True,loc='best')

plt.savefig('heat_gpu_block_scaling.png')


