#!/bin/bash

#PBS -N ROT.M21
#PBS -M kai.wang@mq.edu.au
#PBS -l nodes=21:ppn=8
#PBS -l walltime=00:15:00

# script runs mesher,database generation and solver
# using this example setup
#
###################################################
#=====
module load intel/15.0.2 openmpi/intel/1.6.4
cd $PBS_O_WORKDIR
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/intel/lib/intel64:/usr/local/openmpi/lib
#=====
# number of processes
NPROC=168

#prog=~/progs/SEM_tools/kernel_rotate/kernel_rotate
prog=~/progs/SEM_tools/model_diff/model_add


mpirun -np $NPROC $prog 
