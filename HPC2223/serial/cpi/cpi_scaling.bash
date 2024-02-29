#!/bin/bash

FUNCTION=$1

echo "function,iter,pi,error,t_np,t_p,hostname" > cpi_scaling$FUNCTION.csv

for N in $(seq 1000000 100000 9000000)
#for N  in  1000 2000 3000
do
./cpi -n $N -f $FUNCTION >> cpi_scaling$FUNCTION.csv
done

