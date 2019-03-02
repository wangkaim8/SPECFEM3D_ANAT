#!/bin/bash
#PBS -N KERNE.post.M02
#PBS -M kai.wang@mq.edu.au
#PBS -m abe
#PBS -l nodes=21:ppn=8
#PBS -l walltime=04:15:00

prog=~/progs/specfem3d
module load intel/15.0.2 openmpi/intel/1.6.4
#=====
cd $PBS_O_WORKDIR
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/intel/lib/intel64:/usr/local/openmpi/lib
#=====
mod=M02
NPROC=168
is_sumkern=true
is_smooth=true
is_update=true
###################################################
if $is_sumkern;then
cd optimize/sum_kernels_$mod
rm -f OUTPUT_*_KERNELS/*

### sum kernels
   mpirun -np $NPROC ./bin/xsum_kernels
   mv OUTPUT_SUM OUTPUT_SUM_KERNELS

### preconditioned kernels
   mkdir OUTPUT_SUM
   mpirun -np $NPROC ./bin/xsum_preconditioned_kernels
   #mpirun -np $NPROC ./bin/xprogram05_sum_preconditioned_kernels
   mv OUTPUT_SUM/* OUTPUT_PREC_KERNELS
cd ../..
fi
####################################################
if $is_smooth;then
cd optimize/sum_kernels_$mod
### smooth sumed or preconditioned kernels
### Only alpha & beta kernel is needed in the inversion, rho kernel are scaled to alpha
date
#for knm in alpha_kernel;do
for knm in alpha_kernel beta_kernel;do
   #mpirun -np $NPROC ./bin/xsmooth_sem 10000 5000 $knm OUTPUT_PREC_KERNELS/ OUTPUT_SMOOTH_KERNELS/ FALSE 
   #mpirun -np $NPROC ./bin/xsmooth_sem 20000 10000 $knm OUTPUT_PREC_KERNELS/ OUTPUT_SMOOTH_KERNELS/ FALSE 
   #mpirun -np $NPROC ./bin/xsmooth_sem 15000 7000 $knm OUTPUT_PREC_KERNELS/ OUTPUT_SMOOTH_KERNELS/ FALSE 
   mpirun -np $NPROC ./bin/xsmooth_sem 15000 5000 $knm OUTPUT_PREC_KERNELS/ OUTPUT_SMOOTH_KERNELS/ FALSE 
   #mpirun -np $NPROC ./bin/xprogram03_smooth_sem 20000 5000 $knm OUTPUT_PREC_KERNELS/ OUTPUT_SMOOTH_KERNELS/ FALSE
done
date
cd ../..
echo "Gradient done!"
fi
#######################################################
if $is_update;then
date
#cd ../SD_$mod
cd optimize/SD_$mod
for step in `cat step_len.dat`;do
   rm -rf OUTPUT_MODEL_slen$step
   mkdir OUTPUT_MODEL_slen$step
   mpirun -np $NPROC ./bin/xadd_model_iso $step INPUT_GRADIENT OUTPUT_MODEL_slen$step
#   mpirun -np $NPROC ./bin/xmodel_update $step INPUT_GRADIENT OUTPUT_MODEL_slen$step
#   mpirun -np $NPROC ./bin/xprogram01_add_model_iso $step INPUT_GRADIENT OUTPUT_MODEL_slen$step
#   mpirun -np $NPROC ./bin/xprogram02_model_update $step INPUT_GRADIENT OUTPUT_MODEL_slen$step

done
cd ../..
date
fi
