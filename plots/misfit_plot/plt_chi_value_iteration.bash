#!/bin/bash
#        ! KEY: write misfit function values to file (two for each window)
#        ! Here are the 20 columns of the vector window_chi
#        !  1: MT-TT chi,    2: MT-dlnA chi,    3: XC-TT chi,    4: XC-dlnA chi
#        !  5: MT-TT meas,   6: MT-dlnA meas,   7: XC-TT meas,   8: XC-dlnA meas
#        !  9: MT-TT error, 10: MT-dlnA error, 11: XC-TT error, 12: XC-dlnA error
#        ! WINDOW     : 13: data power, 14: syn power, 15: (data-syn) power, 16: window duration
#        ! FULL RECORD: 17: data power, 18: syn power, 19: (data-syn) power, 20: record duration
#        ! Example of a reduced file: awk '{print $2,$3,$4,$5,$6,$31,$32}' window_chi > window_chi_sub
rm .gmtdefaults4 
#gmtset ANOT_FONT_SIZE_PRIMARY 10
#gmtset LABEL_FONT_SIZE 12

out=chi_iter.ps
range=-R-0.5/7.5/0.0/2.2
xtick=a1
ytick=a0.5
xc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print ($2-$1)/2}'`
yc=`echo $range |awk '{print substr($1,3)}' |awk -F/ '{print $4+0.2}'`
if true;then
for band in T005_T010 T010_T020 T020_T050;do
    echo $band
    cat /dev/null >chi_$band.dat
    for itnm in `seq 0 1 5`;do
       mod=`echo $itnm |awk '{printf"M%02d",$1+16}'`
       if [ $itnm -eq 0 ];then
          misf=`cat ../../output/misfits/$mod/${mod}_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($29!=0) {sum=sum+$29;n=n+1}} END{print sum/n}'`
          #misf=`cat ../../output/misfits/$mod/${mod}_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($13!=0) {sum=sum+$13*$13/$17/$17;n=n+1}} END{print 0.5*sum/n}'`
          #misf=`cat ../../output/misfits/$mod/${mod}_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($15!=0) {sum=sum+$15*$15/$19/$19;n=n+1}} END{print 0.5*sum/n}'`
       else
          misf=`cat ../../output/misfits/$mod/${mod}.set*_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($29!=0) {sum=sum+$29;n=n+1}} END{print sum/n}'`
          #misf=`cat ../../output/misfits/$mod/${mod}.set*_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($13!=0) {sum=sum+$13*$13/$17/$17;n=n+1}} END{print 0.5*sum/n}'`
          #misf=`cat ../../output/misfits/$mod/${mod}.set*_${band}_*_chi |awk 'BEGIN{sum=0;n=0} {if($15!=0) {sum=sum+$15*$15/$19/$19;n=n+1}} END{print 0.5*sum/n}'`
       fi
    echo $itnm $misf $slen  >>chi_$band.dat 
    done
done
fi
#psbasemap -JX11.7/8.3 $range -B"$xtick":"iter number":/"$ytick":"misfits (s)":WSne -K -P -X4 -Y16 >$out
psbasemap -JX11.7/8.3 $range -B"$xtick":"iter number":/"$ytick":"misfits":WSne -K -P -X4 -Y16 >$out
### plot 20-50s for 1stIT to 2thIT
cat chi_T020_T050.dat |psxy -J -R -St0.15i -Gred -O -K >>$out
head -1 chi_T020_T050.dat |awk '{printf"%d %f 12 0 0 CM %.2f\n",$1,$2-0.1,$2}' |pstext -J -R -Gred -O -K >>$out 
### plot 10-50s for 2thIT to 8thIT
cat chi_T010_T020.dat |sed -n '2,8p' |psxy -J -R -Sd0.15i -Gblue -Wblack -O -K >>$out
#cat chi_T010_T050.dat |sed -n '2,8p' |awk '{printf"%f %f 12 0 0 CM %.2f\n",$1-0.5,$2,$2}' |pstext -J -R -Gblue -O -K >>$out 
### plot 5_50s for 6thIT to 8thIT
cat chi_T005_T010.dat |sed -n '4,8p' |psxy -J -R -Sc0.15i -Gcyan -Wblack -O -K >>$out
#cat chi_T005_T050.dat |sed -n '4,8p' |awk '{printf"%f %f 12 0 0 CM %.2f\n",$1+0.5,$2,$2}' |pstext -J -R -Gcyan -O -K >>$out 
### plot 20-50s + 10-50s for 4thIT and 5thIT
cat /dev/null  >chi_20_50_10_20.dat

for i in 1 2;do
  let l=$i+1
  chi1=`cat chi_T020_T050.dat |sed -n "${l}p" |awk '{print $2}'`
  chi2=`cat chi_T010_T020.dat |sed -n "${l}p" |awk '{print $2}'`
  echo $i $chi1 $chi2
  echo $i $chi1 $chi2 |awk '{print $1,($2+$3)/2}' >>chi_20_50_10_20.dat
done
cat chi_20_50_10_20.dat |psxy -J -R -Sa0.15i -Gdarkgreen -Wblack -O -K >>$out
#cat chi_20_50_10_50.dat |awk '{printf"%f %f 12 0 0 CM %.2f\n",$1+0.5,$2,$2}' |pstext -J -R -Gdarkgreen -O -K >>$out 
cat chi_20_50_10_20.dat |awk '{printf"%f %f 12 0 0 CM %.2f\n",$1,$2-0.1,$2}' |pstext -J -R -Gdarkgreen -O -K >>$out 
### plot 20-50s + 10-50s + 5-50s for 6thIT to 8thIT
cat /dev/null  >chi_20_50_10_20_5_10.dat
for i in 3 4 5;do
  let l=$i+1
  chi1=`cat chi_T020_T050.dat |sed -n "${l}p" |awk '{print $2}'`
  chi2=`cat chi_T010_T020.dat |sed -n "${l}p" |awk '{print $2}'`
  chi3=`cat chi_T005_T010.dat |sed -n "${l}p" |awk '{print $2}'`
  echo $i $chi1 $chi2 $chi3 |awk '{print $1,($2+$3+$4)/3}' >>chi_20_50_10_20_5_10.dat
done
cat chi_20_50_10_20_5_10.dat |psxy -J -R -Sh0.15i -Gpurple -Wblack -O -K >>$out
cat chi_20_50_10_20_5_10.dat |awk '{printf"%f %f 12 0 0 CM %.2f\n",$1+0.5,$2,$2}' |pstext -J -R -Gpurple -O -K >>$out 
### plot line of final chi
chi=chi_final.dat
cat /dev/null >$chi
head -1 chi_T020_T050.dat >$chi
cat chi_20_50_10_20.dat >>$chi
cat chi_20_50_10_20_5_10.dat >>$chi
cat $chi |psxy -J -R -W1p -O -K >>$out

cat chi_final.dat |awk  '{printf"%d %f 12 0 0 CM M%s\n",$1,$2+0.1,$1+16}' |pstext -J -R -Gblack -O -K >>$out 
### plot legend
pslegend -J -R -D2.9/2.15/6.5/3.2/LT -F -O <<eof >>$out
S 0.3c t 0.15i red black 0.6c 20_50 s
S 0.3c d 0.15i blue black 0.6c 10_20 s
S 0.3c c 0.15i cyan black 0.6c 5_10 s
S 0.3c a 0.15i darkgreen black 0.6c 20_50 and 10_20 s
S 0.3c h 0.15i purple black 0.6c 20_50, 10_20 and 5-10 s
eof
gs $out

