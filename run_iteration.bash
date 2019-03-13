#!/bin/bash
# This script is used to prepare direcotries and files for running specfem3d.
# Author: Kai Wang, wangkaim8@gmail.com
# University of Toronto, ON, Canada
# Last modified: Tue Dec 22 10:52:28 EDT 2017



mod=M00
step=0.04
oldmod=`echo $mod |awk -FM '{printf"M%02d",$2-1}'`
inv_dir=optimize/SD_$oldmod
#fwd=pbs_mesh_fwd_measure.sh
fwd=pbs_mesh_fwd_measure_adj.sh
for ipart in `seq 1 1 1`;do
  echo "======================================="
  echo Model:$mod Part:$ipart
  echo "========================================"
  #=====
  newmod=$mod.set${ipart}
  cdir=`pwd`
  srfile=sources_set${ipart}.dat
  ####
  nevt=`cat src_rec/$srfile |wc -l`
  echo $nevt "found!!!"
  for evtnum in `seq 1 1 $nevt`;do # loop over all virtual evts
    evtfile=`cat src_rec/$srfile |sed -n "${evtnum}p"`
    eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
    fwd_dir=solver/$newmod/$eid
    echo $eid

    # link all useful files, this is based on that we do forward simulation event by event, so these files are shared but not called simutanous.
    mkdir -p $fwd_dir
    mkdir -p $fwd_dir/bin
    cd $fwd_dir/bin
    ln -sf $cdir/specfem3d/bin/xmeshfem3D .
    ln -sf $cdir/specfem3d/bin/xgenerate_databases .
    ln -sf $cdir/specfem3d/bin/xspecfem3D .
    cd ..
    mkdir -p DATA
    cd DATA
    ln -sf $cdir/specfem3d/DATA/meshfem3D_files .
    ln -sf $cdir/specfem3d/DATA/Par_file .
    if [ $mod == 'M00' ];then
    	sed -i '/MODEL                           =/c\MODEL                           = default' Par_file
    else
    	sed -i '/MODEL                           =/c\MODEL                           = gll' Par_file
    fi
    cd ..
    mkdir -p OUTPUT_FILES
    mkdir -p OUTPUT_FILES/DATABASES_MPI
    cd  OUTPUT_FILES
    ln -sf $cdir/specfem3d/OUTPUT_FILES/*.txt $cdir/specfem3d/OUTPUT_FILES/*.h .
#    cd DATABASES_MPI
#    ln -sf $cdir/specfem3d/OUTPUT_FILES/DATABASES_MPI/* .
    cd $cdir
    cp src_rec/STATIONS_$eid $fwd_dir/DATA/STATIONS 
    cp src_rec/FORCESOLUTION_$eid $fwd_dir/DATA/FORCESOLUTION

    if [ $mod == "M00" ];then
      cd $fwd_dir/OUTPUT_FILES/DATABASES_MPI
      ln -sf $cdir/initial_model/*.bin .
      cd - >/dev/null
    else
      cd $inv_dir/OUTPUT_MODEL_slen$step/
      if [ -f proc000000_vs_new.bin ];then
        rename vp_new.bin vp.bin ./*vp_new.bin
        rename vs_new.bin vs.bin ./*vs_new.bin
        rename rho_new.bin rho.bin ./*rho_new.bin
      fi
      cd - >/dev/null 
      cd $fwd_dir/OUTPUT_FILES/DATABASES_MPI
      ln -sf $cdir/$inv_dir/OUTPUT_MODEL_slen$step/*.bin .
      cd - >/dev/null
    fi
  done
  ################## 
  cp run_preprocessing.2band.sh run_preprocessing.sh
  sed -i "/mod=/c\mod=${newmod}" run_preprocessing.sh
  sed -i "/srfile=/c\srfile=sources_set${ipart}.dat" run_preprocessing.sh
  bash run_preprocessing.sh
  sed -i "/FWD/c\#PBS -N FWD.${newmod}" $fwd
  sed -i "/#PBS -l walltime/c\#PBS -l walltime=04:30:00" $fwd
  sed -i "/srfile=/c\srfile=sources_set${ipart}.dat" $fwd
  sed -i "/is_ls=/c\is_ls=false" $fwd
  sed -i "/mod=/c\mod=${newmod}" $fwd
  #qsub $fwd

done


