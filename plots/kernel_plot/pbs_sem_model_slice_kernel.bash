#!/bin/bash

#PBS -N SLICE.U11A.TT.M21
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

prog=~/progs/SEM_tools/model_slice/sem_model_slice_opt_v3

mod=M21

model_dir=../../solver/M21.set1/CI.STC/OUTPUT_FILES/DATABASES_MPI
#model_dir=CI.STC.M21.event_kernel_diff_TEN2TT_TT
#model_dir=CI.STC-TA.U11A.M21.TEN2TT-TT.beta_kernel
#model_dir=../../solver/CI.STC_26kernels/M21.set23/CI.STC_T/OUTPUT_FILES/DATABASES_MPI
#model_dir=../../optimize/sum_kernels_M21/OUTPUT_SUM_KERNELS

#topo_dir=../../solver/M21.set1/CI.STC_E/OUTPUT_FILES/DATABASES_MPI
topo_dir=OUTPUT_FILES/DATABASES_MPI

# xyz_infile topo_dir model_dir data_name gmt_outfile
# Note: set the right NSPEC_AB when compile the code
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel_smooth raydensity.sm.${newmod}.regridded.xyz 
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel grad.prec.M21.regridded.xyz 
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel CI.STC.set20.M21.TT.kernel.regridded.xyz 
mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel CI.STC.M21.TEN2TT.event_beta_kernel.regridded.xyz 
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel CI.STC-TA.U11A.M21.TEN2TT-TT.beta_kernel.regridded.xyz 
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel CI.STC.M21.event_kernel_diff_TEN2TT_TT.regridded.xyz 
