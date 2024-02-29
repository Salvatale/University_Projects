#!/usr/bin/env python2

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd 

imb_ib = pd.read_csv("IMB.MPI1.ib.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )
imb_opa = pd.read_csv("IMB-MPI1.opa.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )
imb_shm = pd.read_csv("IMB-MPI1.shm.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )

#print (imb.MBps)

plt.title('Confronto della Banda <Alessandro Salvatore>')
plt.grid()
plt.xlabel('dimensione messaggio (bytes)')
plt.xscale('log')
plt.ylabel('MByes/s')


plt.plot(imb_ib.bytes,imb_ib.MBps,'ro',label='infiniband',linestyle='-')
plt.plot(imb_opa.bytes,imb_opa.MBps,'bo',label='omnipath',linestyle='-')
plt.plot(imb_shm.bytes,imb_shm.MBps,'go',label='shared memory',linestyle='-')

plt.legend(shadow=True)

plt.savefig('Confronto_Banda.png')
