#!/bin/bash


mod=M18_slen0.10
srfile=sources_ls.dat

R0=2.8 # minimum group velocity
R1=4.5 # naximum group velocity
#======
is_preproc=true
is_meas_adj=true

is_bd=false # if calculte banana-doughnought kenerl or multi-taper travel-time kernel 
i_plot=false
#------
prog=/home/l/liuqy/kai/specfem3d # seems smoother than stabale version specfem3d_v3.0
fwindir=run_fwin
preprocdir=seis_process_$mod
measdir=measure_adj_$mod
kerndir=sum_kernels
#=======================================
if $is_preproc;then
date
echo "preprocessing ..."
rm -rf $preprocdir
cp -r seis_process $preprocdir
i=1
cat src_rec/$srfile |
while read evtfile; do # loop over all virtual evts
  eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
  fwd_dir=solver/$mod/$eid
  echo $i: $eid
  #-------------
  datadir=data/$eid
  syndir=$fwd_dir/OUTPUT_FILES
  mkdir -p $preprocdir/$eid 
  cd $preprocdir/$eid
  cp ../../src_rec/CMTSOLUTION_$eid CMTSOLUTION # mistake before
  cp ../../$fwd_dir/DATA/STATIONS STATIONS
  ln -sf ../*.pl .
  ln -sf ../asc2sac .
  ln -sf ../ascii2sac.csh .
  mkdir -p DATA_NORM
  cd DATA_NORM
  ln -sf ../../../$datadir/*.sac .
  cd ..
  #cat /dev/null  >process.log 
  cd ..
  echo "cat /dev/null >$eid/process.log" >job$i.sh
  for datf in `ls ../${datadir}/*.sac`;do
    prefix=`echo $datf |awk -F../${datadir}/ '{print $2}' |awk -F.sac '{print $1}'`
    for band in T020_T050;do
      hp=`echo $band |awk '{printf"%d",substr($1,2,3)}'`
      lp=`echo $band |awk '{printf"%d",substr($1,7,3)}'`
      #echo $hp $lp
      #perl process_syn.pl -m $eid/CMTSOLUTION -a $eid/STATIONS -s 100.0 -l -20/235 -t $hp/$lp -x $band ../$syndir/${prefix}.fwd.semd >>$eid/process.log 
      echo "perl process_syn.pl -m $eid/CMTSOLUTION -a $eid/STATIONS -s 100.0 -l -20/235 -t $hp/$lp -x $band ../$syndir/${prefix}.fwd.semd >>$eid/process.log" >>job$i.sh 
      #perl process_syn.pl -m CMTSOLUTION -a STATIONS -s 1.0 -l 0/200 -t 19.9/20.1 -x $band ../$syndir/${prefix}.fwd.semd #>>process.log
      echo "synmin=\`saclst depmin f ../$syndir/${prefix}.fwd.semd.sac.$band |awk '{print \$2}'\` " >>job$i.sh
      echo "synmax=\`saclst depmax f ../$syndir/${prefix}.fwd.semd.sac.$band |awk '{print \$2}'\` ">>job$i.sh
      echo "norm=\`echo \$synmin \$synmax |awk '{if(\$1*\$1>\$2*\$2) {print sqrt(\$1*\$1);} else {print sqrt(\$2*\$2)}}'\`" >>job$i.sh
      #perl process_data.pl -m $eid/CMTSOLUTION -s 100.0 -l -20/235 -t $hp/$lp -v -n -A $norm -x $band ../$datadir/${prefix}.sac >>$eid/process.log
      echo "perl process_data.pl -m $eid/CMTSOLUTION -s 100.0 -l -20/235 -t $hp/$lp -v -n -A \$norm -x $band $eid/DATA_NORM/${prefix}.sac >>$eid/process.log" >>job$i.sh
      #echo $band $synmin $synmax $norm
    done
  done # end loop of stations
  chmod 755 job$i.sh
  cd ..
  let i=i+1
done # end loop over evt
date
cd $preprocdir
cat >run <<EOF
id=\$1
./job\$id.sh
EOF
chmod 755 ./run
cd ../
fi
#=========================================
if $is_meas_adj;then
date
echo "run meas_adj ..."
mkdir -p output/misfits
rm -rf $measdir
mkdir -p $measdir
i=1
cat src_rec/$srfile |
while read evtfile; do # loop over all virtual evts
eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
fwd_dir=solver/$mod/$eid
echo $i: $eid
#-------------
cd $measdir
mkdir -p $eid
echo "cd $eid" >job$i.sh
cd $eid
#cat /dev/null >run.log
echo "cat /dev/null >run.log" >>../job$i.sh

cp ../../src_rec/CMTSOLUTION_$eid .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/measure_adj .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/PAR_FILE .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/scripts_tomo/prepare_measure_adj.pl .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/scripts_tomo/combine_3_adj_src.pl .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/scripts_tomo/run_measure_adj.pl .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/*.pl .
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/rotate_adj_src .
cp -r ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/UTIL .
#mkdir -p DATA
#mkdir -p SYN
mkdir -p OUTPUT_FILES
mkdir -p PLOTS
mkdir -p PLOTS/RECON
cp ../../ADJOINT_TOMOGRAPHY_TOOLS/measure_adj/PLOTS/*.pl PLOTS
cat ../../$fwd_dir/DATA/STATIONS |wc -l >PLOTS/STATIONS_TOMO
cat ../../$fwd_dir/DATA/STATIONS >>PLOTS/STATIONS_TOMO
cp PLOTS/STATIONS_TOMO STATIONS_ADJOINT
for T in T020_T050;do
   hp=`echo $T |awk '{printf"%d",substr($1,2,3)}'`
   lp=`echo $T |awk '{printf"%d",substr($1,7,3)}'`
###---a copy of csh from prepare_measure_adj.pl---###
# link DATA & SYN
#   cd DATA
#   ln -s ../../../data/$eid/*.$T .
    ln -s ../../$preprocdir/$eid/DATA_NORM DATA
#   cd ..
#   cd SYN
#   ln -s ../../../$fwd_dir/OUTPUT_FILES/*HXZ.fwd.semd.sac.$T .
   ln -s ../../$fwd_dir/OUTPUT_FILES SYN
#   cd ..
#---write MEASURE.WINDOWS for the next step
   ls DATA/*.sac |wc -l >MEASUREMENT.WINDOWS
   for rawsac in `ls DATA/*sac`;do
      dist=`saclst dist f $rawsac |awk '{printf"%f",$2}'`
      R0_time=`echo $dist |awk '{printf"%f",$1/v+t/2}' v=$R0 t=$lp`
      R1_time=`echo $dist |awk '{printf"%f",$1/v-t/2}' v=$R1 t=$lp`
      
      datsac=$rawsac.$T
      synsac=`echo $datsac |awk -FDATA/ '{print $2}' |awk -F.sac.$T '{printf"SYN/%s.fwd.semd.sac.%s",$1,t}' t=$T ` 
      echo $datsac >>MEASUREMENT.WINDOWS
      echo $synsac >>MEASUREMENT.WINDOWS
      echo 1 >>MEASUREMENT.WINDOWS
      echo $R1_time $R0_time >>MEASUREMENT.WINDOWS
   done
#--- for plot
#  if $i_plot;then
#  rm -rf PLOTS/SYN
#  mkdir PLOTS/SYN
#  cd PLOTS/SYN
#  ln -s ../../../../$fwd_dir/OUTPUT_FILES/*HXZ.fwd.semd.sac.$T .
#  cd ../../
#  rm -rf PLOTS/DATA
#  mkdir -p PLOTS/DATA
#  cd PLOTS/DATA
#  ln -s ../../../../data/$eid/*.$T .
#  cd ../../
#  rm -f PLOTS/*pdf PLOTS/*jpg PLOTS/*ps
#  cp ./MEASUREMENT.WINDOWS PLOTS
#  fi
###---end of prepare_measure_adj.pl---###
   if $is_bd;then
    #for banana-doughtnut kernel
     ./run_measure_adj.pl $mod -20/235 0 0 0 -2.0/0.01/24000 3 HX $hp/$lp 0/1/1/1 -5.0/5.0/-1.5/1.5/0.7 1/1.0/0.5 2/0.02/2.5/2.0/2.5/3.5/1.5 >>run.log
   else
    #for multi-taper travel time difference
    if $i_plot;then
      #./run_measure_adj.pl $mod -20/235 0 1 0 -2.0/0.01/24000 7 HX $hp/$lp 0/1/1/1 -5.0/5.0/-1.5/1.5/0.7 1/1.0/0.5 1/0.02/2.5/2.0/2.5/3.5/1.5 >>run.log
      echo "./run_measure_adj.pl $mod -20/235 0 1 0 -2.0/0.01/24000 7 HX $hp/$lp 0/1/1/1 -5.0/5.0/-1.5/1.5/0.7 1/1.0/0.5 1/0.02/2.5/2.0/2.5/3.5/1.5 >>run.log" >>../job$i.sh
    else
      #./run_measure_adj.pl $mod -20/235 0 0 0 -2.0/0.01/24000 7 HX $hp/$lp 0/1/1/1 -5.0/5.0/-1.5/1.5/0.7 1/1.0/0.5 1/0.02/2.5/2.0/2.5/3.5/1.5 >>run.log
      echo "./run_measure_adj.pl $mod -20/235 0 0 0 -2.0/0.01/24000 7 HX $hp/$lp 0/0/0/1 -5.0/5.0/-1.5/1.5/0.7 1/1.0/0.5 1/0.02/2.5/2.0/2.5/3.5/1.5 >>run.log" >>../job$i.sh
    fi
   fi
  # 
#   mv ADJOINT_SOURCES ADJOINT_SOURCES_$T
   if $i_plot;then
   echo "mkdir -p PLOTS_$T" >>../job$i.sh
   echo "mv PLOTS/*.pdf PLOTS_$T" >>../job$i.sh
   fi
   #---store travel time and amplitue misfit of each window 
   #cat window_chi |awk '{print a,$1,$15,$19,$13,$17}' a=$eid >> ../output/misfits/misfits_${mod}_${T}_HXZ.dat
   #mv window_chi ../../output/misfits/${mod}_${T}_${eid}_window_chi
   echo "mv window_chi ../../output/misfits/${mod}_${T}_${eid}_window_chi" >>../job$i.sh
done # end loop of T

#----combine adjoint  of three different bands---
#./combine_3_adj_src.pl HX ADJOINT_SOURCES_T008_T020 ADJOINT_SOURCES_T015_T030 ADJOINT_SOURCES_T020_T040 ADJOINT_SOURCES iker07 iker07 iker07 >>run.log

#------- write SEM
echo "cd ../../" >>../job$i.sh
#-------
cat >>../job$i.sh <<EOF
cdir=\`pwd\`
cd $fwd_dir
rm -rf SEM
mkdir -p SEM

cd SEM
for meas_adj in \`ls \$cdir/$measdir/$eid/ADJOINT_SOURCES/*.adj\`;do
    adj=\`echo \$meas_adj |awk -F\$cdir/$measdir/$eid/ADJOINT_SOURCES/ '{print \$2}'\`
    stnm=\`echo \$adj |awk -F. '{print \$1}'\`
    net=\`echo \$adj |awk -F. '{print \$2}'\`
    ch=\`echo \$adj |awk -F. '{print \$3}'\`
    adj_new=\$net.\$stnm.\$ch.adj
    mv \$meas_adj \$adj_new    
    cat \$cdir/$measdir/$eid/ADJOINT_SOURCES/STATIONS_ADJOINT |sed -n '2,\$p' >../DATA/STATIONS_ADJOINT    
done
cd .. # done of make adj
cd \$cdir
EOF
#echo "rm -r $measdir" >>../job$i.sh
chmod 755 ../job$i.sh
#----
cd ../../
cd $measdir
cat >run <<EOF
id=\$1
./job\$id.sh
EOF
chmod 755 ./run
cd ../

#
let i=i+1
done # end of loop over evts
date
fi
#=================================================

