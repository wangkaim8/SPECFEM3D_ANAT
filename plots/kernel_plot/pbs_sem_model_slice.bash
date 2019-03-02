#!/bin/bash

#PBS -N SLICE.M21
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

prog=~/progs/model_slice/sem_model_slice_opt_v3

mod=M20
newmod=`echo $mod |awk -FM '{printf"M%d\n",$2+1}'`
#model_dir=../../output/model_${mod}
#model_dir=../../optimize/sum_kernels_M21_raydensity/OUTPUT_SMOOTH_KERNELS

#model_dir=../../optimize/sum_kernels_M21.gaus02/OUTPUT_PREC_KERNELS
#model_dir=../../optimize/sum_kernels_M21/OUTPUT_PREC_KERNELS
model_dir=../../optimize/sum_kernels_M21/OUTPUT_MODEL

topo_dir=../../specfem3d/OUTPUT_FILES/DATABASES_MPI
# xyz_infile topo_dir model_dir data_name gmt_outfile
# Note: set the right NSPEC_AB when compile the code
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel_smooth raydensity.sm.${newmod}.regridded.xyz 
#mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel grad.prec.M21.regridded.xyz 
mpirun -np $NPROC $prog xyz.dat $topo_dir $model_dir beta_kernel_smooth_Hdm Hdm_smooth.gaus02.M21.regridded.xyz 
