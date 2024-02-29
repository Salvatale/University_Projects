import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd


matrix_dim = [x for x in range(100,4000,200)]
cpu = pd.read_csv("data_cpu.txt",sep=' ', names=["time","GFLOPS"])
coalescing = pd.read_csv("data_coalescing.txt",sep=' ', names=["time","GFLOPS"])
naive = pd.read_csv("data_naive.txt",sep=' ', names=["time","GFLOPS"])
tiling = pd.read_csv("data_tiling.txt",sep=' ', names=["time","GFLOPS"])

plt.title('Matrix Multiplication - time')
plt.grid()
plt.xlabel('Matrix dimension')
plt.ylabel('Time')
plt.plot(matrix_dim,cpu.time,'b-o', label='CPU')
plt.plot(matrix_dim,naive.time,'g-o', label='NAIVE')
plt.plot(matrix_dim,coalescing.time,'y-o', label='COALESCING')
plt.plot(matrix_dim,tiling.time,'r-o', label='TILING')

plt.legend(shadow=True,loc='best')
plt.savefig('MUL-time.png')

plt.title('Matrix Multiplication - GFLOPS')
plt.grid()
plt.xlabel('Matrix dimension')
plt.ylabel('GFLOPS')
plt.plot(matrix_dim,cpu.GFLOPS,'b-o', label='CPU')
plt.plot(matrix_dim,naive.GFLOPS,'g-o', label='NAIVE')
plt.plot(matrix_dim,coalescing.GFLOPS,'y-o', label='COALESCING')
plt.plot(matrix_dim,tiling.GFLOPS,'r-o', label='TILING')



plt.savefig('MUL-GFLOPS.png')
