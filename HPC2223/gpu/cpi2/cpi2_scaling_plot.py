#!/usr/bin/env python2

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd

cpi2 = pd.read_csv("cpi2_scaling.dat",sep=',', names=["Num_blocks","time","error","total"])


plt.title('Performance cpi2.cu')
plt.grid()
plt.xlabel('Number of blocks')
plt.ylabel('Time')
plt.plot(cpi2.Num_blocks,cpi2.time,'b-o')


plt.savefig('cpi2_performance.png')

plt.title('Error cpi2.cu')
plt.grid()
plt.xlabel('Number of blocks')
plt.ylabel('Error')
plt.plot(cpi2.Num_blocks,cpi2.error,'b-o')


plt.savefig('cpi2_error.png')
