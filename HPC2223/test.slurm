#!/bin/bash
##SBATCH --output=%x.o%j  # Nome del file per lo strandard output
###SBATCH --error=%x.e%j  # Se non specificato stderr e' rediretto su stdout
##SBATCH --partition=cpu             # Nome della partizione
##SBATCH --cpus-per-task=1            # numero di cpu
###SBATCH --mem=2G                    # massima memoria utilizzata
##SBATCH --time=0-00:10:00            # massimo tempo di calcolo
##SBATCH --account=T_2022_HPCPROGPAR  # account da utilizzare (per gli studenti del corso e' il default)
##SBATCH --qos=cpu                     # Nome della partizione
###SBATCH --qos=cpu_guest             # CPU_GUEST: nodi ci calcolo privati ma non utilizzati
###SBATCH --partition=cpu_guest       # Nome della partizione
##SBATCH --nodes=1                    # numero di nodi richiesti
