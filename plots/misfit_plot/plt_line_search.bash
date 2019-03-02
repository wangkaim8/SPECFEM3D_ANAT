#!/bin/bash
gmtset ANOT_FONT_SIZE_PRIMARY 10
gmtset LABEL_FONT_SIZE 12

mod=$1
out=mis_${mod}_linesearch.ps
range=-R-0.01/0.15/0.0/2.0
xtick=a0.03f0.01
ytick=a0.5
xc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print ($2-$1)/2}'`
yc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print $4+0.2}'`
ln -sf ../../output/misfits/misfits_${mod}_*.dat .

for band in T008_T020 T015_T030 T020_T040;do
  echo $band
  cat /dev/null >$mod.$band.mis
  misf=`cat misfits_${mod}_${band}*.dat |awk 'BEGIN{sum=0;n=0} {if($4!="NaN") {sum=sum+$3*$3/$4/$4;n=n+1}} END{print sqrt(sum/n)}'`
#  misf=`cat misfits_${mod}_${band}*.dat |awk 'BEGIN{sum=0;n=0} {if($6!=0.0) {sum=sum+$5*$5/$6/$6;n=n+1}} END{print sum/n}'`
  echo 0.0 $misf >>$mod.$band.mis
  for step in `cat ../../slen.dat`;do
    sc=misfits_${mod}_slen${step}_${band}*.dat
    misf=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($4!="NaN") {sum=sum+$3*$3/$4/$4;n=n+1}} END{print sqrt(sum/n)}'`
#    misf=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($6!=0.0) {sum=sum+$5*$5/$6/$6;n=n+1}} END{print sum/n}'`
    echo $step $misf >>$mod.$band.mis
  done
done 
ifig=1
for band in T008_T020 T015_T030 T020_T040;do
  #echo ifig=$ifig: $band
  if [ $ifig -eq 1 ];then
     psbasemap -JX5 $range -B"$xtick":"step length":/"$ytick":"misfits (s)":WSne -K -P -Y18 > $out
     pstext -J -R -N -K -O >>$out <<eof
$xc $yc 12 0 0 CM $band
eof
     cat $mod.$band.mis |psxy -JX -R -Sa0.25 -Gblue -O -K >> $out
  elif [ $ifig -lt 3 ];then
     psbasemap -JX5 $range -B"$xtick":"step length":/"$ytick":"misfits (s)":wSne -K -O -X5.5 >> $out
     pstext -J -R -N -K -O >>$out <<eof
$xc $yc 12 0 0 CM $band
eof
     cat $mod.$band.mis |psxy -JX -R -Sa0.25 -Gblue -O -K >> $out
  else
     psbasemap -JX5 $range -B"$xtick":"step length":/"$ytick":"misfits (s)":wSnE -K -O -X5.5 >> $out
     pstext -J -R -N -K -O >>$out <<eof
$xc $yc 12 0 0 CM $band
eof
     cat $mod.$band.mis |psxy -JX -R -Sa0.25 -Gblue -O -K >> $out
  fi
  let ifig=ifig+1
  cat $mod.$band.mis |awk '{print $1}' |sort -n >slen.dat
done
##### plot averaged misfit by bands #####
cat /dev/null >$mod.mis.avg
for slen in `cat slen.dat `;do
   sum=0.0
   for band in T008_T020 T015_T030 T020_T040;do
      misf=`cat $mod.$band.mis |awk '{if($1==a) print $2}' a=$slen`
      sum=`echo $sum + $misf |bc -l`
   done
   sum=`echo $sum/3 |bc -l`
   echo $slen $sum >>$mod.mis.avg
done
psbasemap -JX5 $range -B"$xtick":"step length":/"$ytick":"misfits (s)":WSne -K -O -X-5.5 -Y-8.5 >> $out
pstext -J -R -N -K -O >>$out <<eof
$xc $yc 12 0 0 CM Overall Band
eof
cat $mod.mis.avg |psxy -JX -R -Sa0.25 -Gblue -O -K >> $out
head -1 $mod.mis.avg |psxy -JX -R -Sa0.25 -Ggreen -O -K >> $out
head -1 $mod.mis.avg |awk '{printf"%f %f 12 0 0 BC M00\n",$1,$2+0.1}' |pstext -J -R -N -K -O >>$out
minval=`minmax -C $mod.mis.avg |awk '{print $3}'`
cat $mod.mis.avg | awk '{if(($2-a)<0.0001) print $1,$2}' a=$minval |psxy -JX -R -Sa0.25 -Gred -O -K >> $out
cat $mod.mis.avg | awk '{if(($2-a)<0.0001) printf"%f %f 12 0 0 BC M01\n",$1,$2+0.1}' a=$minval |pstext -J -R -N -K -O >>$out

cat /dev/null |psxy -J -R -O >> $out

