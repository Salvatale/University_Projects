#!/usr/bin/env python2

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd

heat = pd.read_csv("heat_gpu_scaling.txt",sep=',', names=["blockSize","time"])

plt.title('Heat_gpu scaling')
plt.grid()
plt.xlabel('Dimensione blocco')
plt.ylabel('Tempo')
plt.plot(heat.blockSize,heat.time,'b-o')

plt.savefig('heat_gpu_scaling.png')


