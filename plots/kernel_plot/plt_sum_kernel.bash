#!/bin/bash
mod=M21
prog=/home/l/liuqy/kai/progs/specfem3d
module load intel/15.0.2 openmpi/intel/1.6.4


slicefile=slice.lst
seq 0 1 167 >$slicefile
for type in SUM;do
in_path=../../optimize/sum_kernels_$mod/OUTPUT_${type}_KERNELS/
#in_path=../../$fwd_dir/OUTPUT_FILES/DATABASES_MPI/
out_path=${type}_KERNELS_$mod/
#ln -sf $prog/bin . 
#ln -sf  ../../specfem3d/DATA .
#ln -sf  ../../specfem3d/OUTPUT_FILES .
mkdir -p $out_path
for tag in beta_kernel #alpha_kernel kappa_kernel mu_kernel rho_kernel rhop_kernel
do
   $prog/bin/xcombine_vol_data $slicefile $tag $in_path $out_path 0
done
done

