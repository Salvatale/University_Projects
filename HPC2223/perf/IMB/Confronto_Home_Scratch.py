#!/usr/bin/env python2

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd 

imb_home_read = pd.read_csv("IMB-IO-S_Read-indv.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )
imb_home_write = pd.read_csv("IMB-IO-S_Write-indv.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )
imb_scratch_read = pd.read_csv("IMB-IO-S_Read-indv_scratch.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )
imb_scratch_write = pd.read_csv("IMB-IO-S_Write-indv_scratch.dat",comment="#", sep='\s+',  names=["bytes", "repetitions","time","MBps"] )

#print (imb.MBps)

plt.title('Confronto Letture e Scritture tra Scracth ed Home  <Alessandro Salvatore>')
plt.grid()
plt.xlabel('dimensione messaggio (bytes)')
plt.xscale('log')
plt.ylabel('MByes/s')


plt.plot(imb_home_read.bytes,imb_home_read.MBps,'ro',label='letture home',linestyle='-')
plt.plot(imb_home_write.bytes,imb_home_write.MBps,'yo',label='scritture home',linestyle='-')
plt.plot(imb_scratch_read.bytes,imb_scratch_read.MBps,'bo',label='letture scratch',linestyle='-')
plt.plot(imb_scratch_write.bytes,imb_scratch_write.MBps,'go',label='scritture scratch',linestyle='-')

plt.legend(shadow=True)

plt.savefig('Confronto_Home_Scratch.png')
