#!/bin/bash
mod=M21
prog=/home/l/liuqy/kai/progs/specfem3d
module load intel/15.0.2 openmpi/intel/1.6.4



grep STC ../../src_rec/sources.dat |
while read evtfile; do # loop over all virtual evts
eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
fwd_dir=solver/$mod/$eid
echo $eid

slicefile=slice.lst
seq 0 1 167 >$slicefile

#in_path=../../optimize/sum_kernels_$mod/INPUT_KERNELS/${eid}_DATABASES_MPI/
in_path=../../${fwd_dir}_E/OUTPUT_FILES/DATABASES_MPI/
out_path=event_kernel_${eid}_${mod}_TE/
ln -sf $prog/bin . 
ln -sf  ../../specfem3d/DATA .
ln -sf  ../../specfem3d/OUTPUT_FILES .

mkdir -p $out_path
for tag in beta_kernel #alpha_kernel kappa_kernel mu_kernel rho_kernel rhop_kernel
do
   $prog/bin/xcombine_vol_data $slicefile $tag $in_path $out_path 0
done

done
