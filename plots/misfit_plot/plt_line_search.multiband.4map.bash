#!/bin/bash
#        ! KEY: write misfit function values to file (two for each window)
#        ! Here are the 20 columns of the vector window_chi
#        !  1: MT-TT chi,    2: MT-dlnA chi,    3: XC-TT chi,    4: XC-dlnA chi
#        !  5: MT-TT meas,   6: MT-dlnA meas,   7: XC-TT meas,   8: XC-dlnA meas
#        !  9: MT-TT error, 10: MT-dlnA error, 11: XC-TT error, 12: XC-dlnA error
#        ! WINDOW     : 13: data power, 14: syn power, 15: (data-syn) power, 16: window duration
#        ! FULL RECORD: 17: data power, 18: syn power, 19: (data-syn) power, 20: record duration
#        ! Example of a reduced file: awk '{print $2,$3,$4,$5,$6,$31,$32}' window_chi > window_chi_sub
 
#gmtset ANOT_FONT_SIZE_PRIMARY 10
#gmtset LABEL_FONT_SIZE 12
mod=$1
out=mis_${mod}_linesearch.ps
range=-R-0.01/0.16/0.5/2.5
xtick=a0.03f0.01
ytick=a0.5
xc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print ($2-$1)/2}'`
yc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print $4*0.95}'`

for band in T010_T050 T020_T050;do
  echo $band
  cat /dev/null >$mod.$band.mis
#  misf=`cat ../../output/misfits/$mod/${mod}_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($9>0) {sum=sum+$9;n=n+1}} END{print sum/n}'`
#  misf=`cat misfits_${mod}_${band}*.dat |awk 'BEGIN{sum=0;n=0} {if($6!=0.0) {sum=sum+$5*$5/$6/$6;n=n+1}} END{print sum/n}'`
#  echo 0.0 $misf >>$mod.$band.mis
  for step in `seq 0.02 0.02 0.04`;do
    input=chi_${mod}_slen${step}_${band}.dat
    cat /dev/null >$input
    for file in `ls ../../output/misfits/${mod}/${mod}_slen${step}_${band}_*_chi`;do
      evt=`echo $file |awk -F../../output/misfits/${mod}/ '{print $2}' |awk -F_ '{print $4 }'`
# MTTT dT & sigma
#    cat $file |awk '{print a,$1,$13,$17}' a=$evt >>$input.all
#    cat $file |awk '{if($15*$15>0) print a,$1,$13,$17}' a=$evt >>$input
# XCTT dT & sigma
#    cat $file |awk '{print a,$1,$15,$19}' a=$evt >>$input.all
#    cat $file |awk '{if($15*$15>0) print a,$1,$15,$19}' a=$evt >>$input
## MTTT
#      cat $file |awk '{print a,$1,$9}' a=$evt >>$input.all
#      cat $file |awk '{if($9>0) print a,$1,$9}' a=$evt >>$input
## XCTT
#      cat $file |awk '{print a,$1,$11}' a=$evt >>$input.all
#      cat $file |awk '{if($9>0) print a,$1,$11}' a=$evt >>$input
## chi value final (MTTT & XCTT)
      cat $file |awk '{print a,$1,$29}' a=$evt >>$input.all
      cat $file |awk '{if($29!=0) print a,$1,$29}' a=$evt >>$input
#
    done 
    sc=chi_${mod}_slen${step}_${band}*.dat
### For MTTT/XCTT chi value
    misf=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($3>0) {sum=sum+$3;n=n+1}} END{print sum}'`
    nmeas=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($3>0) {n=n+1}} END{print n}'`
    mis=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($3>0) {sum=sum+$3;n=n+1}} END{print sum/n}'`
### MTTT/XCTTT dt and sigma, chi value 
#    misf=`cat $sc |awk 'BEGIN{sum=0;n=0} {if($3*$3>0) {sum=sum+$3*$3/$4/$4;n=n+1}} END{print sum/n}'`
    echo $step $misf $nmeas $mis >>$mod.$band.mis
  done
done 
echo "delete chi_${mod}*"
rm chi_${mod}_slen*_${band}*
##### plot averaged misfit by bands #####
cat /dev/null >$mod.mis.avg
for slen in `seq 0.02 0.02 0.14 `;do
   sumf=0.0
   sumn=0
   for band in T010_T050 T020_T050;do
      misf=`cat $mod.$band.mis |awk '{if($1==a) print $2}' a=$slen`
      nmeas=`cat $mod.$band.mis |awk '{if($1==a) print $3}' a=$slen`
      sumf=`echo $sumf + $misf |bc -l`
      sumn=`echo $sumn + $nmeas |bc -l`
   done
   sum=`echo $sumf/$sumn |bc -l`
   echo $slen $sum >>$mod.mis.avg
done
exit
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

exit
ifig=1
for band in T020_T050;do
  #echo ifig=$ifig: $band
  if [ $ifig -eq 1 ];then
     psbasemap -JX9 $range -B"$xtick":"step length":/"$ytick":"misfits (s)":WSne -K -P -Y18 > $out
     pstext -J -R -N -K -O >>$out <<eof
$xc $yc 12 0 0 CM $mod:$band
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
cat /dev/null |psxy -J -R -O >> $out

