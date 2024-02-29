import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd


omp_gnu4 = pd.read_csv('omp_heat_gnu4.dat', sep=',',header=0)
omp_gnu8 = pd.read_csv('omp_heat_gnu8.dat', sep=',',header=0)
omp_intel = pd.read_csv('omp_heat_intel.dat', sep=',',header=0)

print(omp_gnu4.Thread)

#confronto tra il tempo parallelo e non parallelo utilizzando il compilatore gnu4
plt.title('omp_heat TP VS TNP (gnu4)')
plt.grid()
plt.xlabel('thread')
plt.ylabel('tempo')
plt.plot(omp_gnu4.Thread,omp_gnu4.Tp,'r-o',label='Tempo parallelo')
plt.plot(omp_gnu4.Thread,omp_gnu4.Tnp,'b-o',label='Tempo seriale')
plt.legend(shadow=True,loc='upper right')
plt.savefig('omp_heat_gnu4.png')

plt.clf()


#confronto tra il tempo parallelo e non parallelo utilizzando il compilatore gnu8
plt.title('omp_heat TP VS TNP (gnu8)')
plt.grid()
plt.xlabel('thread')
plt.ylabel('tempo')
plt.plot(omp_gnu8.Thread,omp_gnu8.Tp,'r-o',label='Tempo parallelo')
plt.plot(omp_gnu8.Thread,omp_gnu8.Tnp,'b-o',label='Tempo seriale')
plt.legend(shadow=True,loc='upper right')
plt.savefig('omp_heat_gnu8.png')

plt.clf()

#confronto tra il tempo parallelo e non parallelo utilizzando il compilatore intel
plt.title('omp_heat TP VS TNP (intel)')
plt.grid()
plt.xlabel('thread')
plt.ylabel('tempo')
plt.plot(omp_intel.Thread,omp_intel.Tp,'r-o',label='Tempo parallelo')
plt.plot(omp_intel.Thread,omp_intel.Tnp,'b-o',label='Tempo seriale')
plt.legend(shadow=True,loc='upper right')
plt.savefig('omp_heat_intel.png')

plt.clf()

#confronto dei tempi paralleli dei tre compilatori
plt.title('confronto tra compilatori')
plt.grid()
plt.xlabel('thread')
plt.ylabel('tempo')
plt.plot(omp_gnu4.Thread,omp_gnu4.Tp,'r-o',label='GNU4')
plt.plot(omp_gnu8.Thread,omp_gnu8.Tp,'b-o',label='GNU8')
plt.plot(omp_intel.Thread,omp_intel.Tp,'g-o',label='INTEL')
plt.legend(shadow=True,loc='upper right')
plt.savefig('omp_heat_confronto.png')

plt.clf()

