import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt 
import pandas as pd 

cpi1 = pd.read_csv("cpi_scaling1.csv")
cpi2 = pd.read_csv("cpi_scaling2.csv")

#Grafico Funzione 1 per t_np e t_p

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('tempo')
plt.plot(cpi1.iter,cpi1.t_np,'r-o',label='Tnp')
plt.plot(cpi1.iter,cpi1.t_p,'g-o',label='Tp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_tempo_tp_tnp_f1.png')

plt.clf()

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('quote')
plt.plot(cpi1.iter,cpi1.t_np/(cpi1.t_p+cpi1.t_np),'r-o',label='Qnp')
plt.plot(cpi1.iter,cpi1.t_p/(cpi1.t_p+cpi1.t_np),'g-o',label='Qp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_quote_tp_tnp_f1.png')

plt.clf()

#Grafico Funzione 2 per t_np e t_p

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('tempo')
plt.plot(cpi2.iter,cpi2.t_np,'r-o',label='Tnp')
plt.plot(cpi2.iter,cpi2.t_p,'g-o',label='Tp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_tempo_tp_tnp_f2.png')

plt.clf()

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('quote')
plt.plot(cpi2.iter,cpi2.t_np/(cpi2.t_p+cpi2.t_np),'r-o',label='Qnp')
plt.plot(cpi2.iter,cpi2.t_p/(cpi2.t_p+cpi2.t_np),'g-o',label='Qp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_quote_tp_tnp_f2.png')

plt.clf()


#Grafico Funzione 1-2 per t_np

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('tempo')
plt.plot(cpi1.iter,cpi1.t_np,'r-o',label='f1-tnp')
plt.plot(cpi2.iter,cpi2.t_np,'g-o',label='f2-tnp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_tempo_tnp_f1-2.png')

plt.clf()

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('quote')
plt.plot(cpi1.iter,cpi1.t_np/(cpi1.t_p+cpi1.t_np),'r-o',label='f1-tnp')
plt.plot(cpi2.iter,cpi2.t_np/(cpi2.t_p+cpi2.t_np),'b-o',label='f2-tnp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_quote_tnp_f1-2.png')


plt.clf()


#Grafico Funzione 1-2 per t_p

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('tempo')
plt.plot(cpi1.iter,cpi1.t_p,'r-o',label='f1-tp')
plt.plot(cpi2.iter,cpi2.t_p,'b-o',label='f2-tp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_tempo_tp_f1-2.png')

plt.clf()

plt.title('CPI  Legge di Amdahl  -   Roberto Alfieri  <data>')
plt.grid()
plt.xlabel('Intervalli')
#plt.yscale('log')
plt.ylabel('quote')
plt.plot(cpi1.iter,cpi1.t_p/(cpi1.t_p+cpi1.t_np),'b-o',label='f1-tp')
plt.plot(cpi2.iter,cpi2.t_p/(cpi2.t_p+cpi2.t_np),'r-o',label='f2-tp')
plt.legend(shadow=True)
plt.savefig('cpi_scaling_quote_tp_f1-2.png')
