#!/bin/bash
mod=M02
inv_dir=optimize/SD_$mod
fwd=pbs_mesh_fwd_measure.sh
#for step in `seq 0.02 0.02 0.14`;do
for step in 0.03 0.05;do
  echo "======================================="
  echo Model:$mod Step Lenth:$step
  echo "========================================"
  #=====
  newmod=${mod}_slen${step}
  cdir=`pwd`
  srfile=sources_ls.dat
  ####
  nevt=`cat src_rec/$srfile |wc -l`
  echo $nevt "found!!!"
  for evtnum in `seq 1 1 $nevt`;do # loop over all virtual evts
    evtfile=`cat src_rec/$srfile |sed -n "${evtnum}p"`
    eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
    fwd_dir=solver/$newmod/$eid
    echo $eid

    # link all useful files, this is based on that we do forward simulation event by event, so these files are shared but not called simutanous.
    rm -rf $fwd_dir
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
    sed -i '/MODEL                           =/c\MODEL                           = gll' Par_file
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

#    date
    # copy *vp_new.bin *vs_new.bin *rho_new.bin to specfem3d/DATA/gll
#    cp $inv_dir/OUTPUT_MODEL_slen$step/*vp_new.bin $fwd_dir/OUTPUT_FILES/DATABASES_MPI
#    cp $inv_dir/OUTPUT_MODEL_slen$step/*vs_new.bin $fwd_dir/OUTPUT_FILES/DATABASES_MPI
#    cp $inv_dir/OUTPUT_MODEL_slen$step/*rho_new.bin $fwd_dir/OUTPUT_FILES/DATABASES_MPI
    cd $inv_dir/OUTPUT_MODEL_slen$step/
    if [ -f proc000167_vs_new.bin ];then
    rename vp_new.bin vp.bin ./*vp_new.bin
    rename vs_new.bin vs.bin ./*vs_new.bin
    rename rho_new.bin rho.bin ./*rho_new.bin
    fi
    cd - >/dev/null 
    cd $fwd_dir/OUTPUT_FILES/DATABASES_MPI
    ln -sf $cdir/$inv_dir/OUTPUT_MODEL_slen$step/*.bin .
    cd - >/dev/null
 done
  
  cp run_preprocessing.1band.sh run_preprocessing.sh
  sed -i "/mod=/c\mod=${newmod}" run_preprocessing.sh
  sed -i "/srfile=/c\srfile=$srfile" run_preprocessing.sh
  ./run_preprocessing.sh
  sed -i "/FWD/c\#PBS -N FWD.${newmod}" $fwd
  sed -i "/#PBS -l walltime/c\#PBS -l walltime=8:30:00" $fwd
  sed -i "/srfile=/c\srfile=$srfile" $fwd
  sed -i "/is_ls=/c\is_ls=true" $fwd
  sed -i "/mod=/c\mod=${newmod}" $fwd
  qsub $fwd

done


