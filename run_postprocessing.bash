#!/bin/bash

mod=M02
step=0.08
oldmod=`echo $mod |awk -FM '{printf"M%02d",$2-1}'`
inv_dir=optimize/SD_$oldmod
prog=/home/l/liuqy/kai/progs/specfem3d
#========
is_sumkern=true
is_update=true

sumkern_dir=optimize/sum_kernels_$mod
cg_dir=optimize/SD_$mod

mkdir -p optimize
cd solver
if [ ! -d $mod ];then
  mkdir -p $mod
  mv ${mod}.set*/* $mod
  rmdir ${mod}.set*
fi
cd ..
#====================================
if $is_sumkern;then
mkdir -p $sumkern_dir
#-----------------------
echo "p"
cd $sumkern_dir

ln -s ../../specfem3d/bin .
ln -s ../../specfem3d/DATA .
ln -s ../../specfem3d/OUTPUT_FILES .
cd -
mkdir -p $sumkern_dir/OUTPUT_SUM
mkdir -p $sumkern_dir/OUTPUT_PREC_KERNELS
mkdir -p $sumkern_dir/INPUT_KERNELS
mkdir -p $sumkern_dir/OUTPUT_SMOOTH_KERNELS

cat /dev/null >$sumkern_dir/kernels_list.txt
cat src_rec/sources.dat |
while read evtfile; do # loop over all virtual evts
eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
echo $eid
fwd_dir=solver/$mod/$eid

if [ ! -d $sumkern_dir/INPUT_KERNELS/${eid}_DATABASES_MPI ];then
   mkdir -p $sumkern_dir/INPUT_KERNELS/${eid}_DATABASES_MPI
   cd $sumkern_dir/INPUT_KERNELS/${eid}_DATABASES_MPI
   ln -s ../../../../$fwd_dir/OUTPUT_FILES/DATABASES_MPI/*kernel.bin .
   cd -
else
   echo "${eid}_DATABASES_MPI exist !!!"
fi
is_file=`ls $sumkern_dir/INPUT_KERNELS/${eid}_DATABASES_MPI/*.bin 2>/dev/null |wc -l`
if [ $is_file -gt 1 ];then
   echo ${eid}_DATABASES_MPI >>$sumkern_dir/kernels_list.txt
fi
done

fi
#============================================================
if $is_update;then
echo "prepare for model update ..."
rm -rf $cg_dir
mkdir -p $cg_dir
cd $cg_dir
seq 0.02 0.02 0.14 >step_len.dat
ln -s ../../specfem3d/bin .
ln -s ../../specfem3d/DATA .
ln -s ../../specfem3d/OUTPUT_FILES .

ln -s ../sum_kernels_$mod/OUTPUT_SMOOTH_KERNELS INPUT_GRADIENT
if [ $mod == "M00" ];then
   echo "using initial model"
   ln -s ../../model_1d_socal INPUT_MODEL
else
   ln -s ../SD_$oldmod/OUTPUT_MODEL_slen$step INPUT_MODEL
fi
#mkdir -p INPUT_MODEL
#cp  ../../output/model_$mod/*vp.bin INPUT_MODEL   
#cp ../../output/model_$mod/*vs.bin INPUT_MODEL   
#cp ../../output/model_$mod/*rho.bin INPUT_MODEL   
#mkdir -p topo
ln -s OUTPUT_FILES/DATABASES_MPI topo
#cp ../../optimize/pbs_inversion.bash .
cd - >/dev/null
fi

