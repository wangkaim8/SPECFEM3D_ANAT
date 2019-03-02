#!/bin/bash
#        ! KEY: write misfit function values to file (two for each window)
#        ! Here are the 20 columns of the vector window_chi
#        !  1: MT-TT chi,    2: MT-dlnA chi,    3: XC-TT chi,    4: XC-dlnA chi
#        !  5: MT-TT meas,   6: MT-dlnA meas,   7: XC-TT meas,   8: XC-dlnA meas
#        !  9: MT-TT error, 10: MT-dlnA error, 11: XC-TT error, 12: XC-dlnA error
#        ! WINDOW     : 13: data power, 14: syn power, 15: (data-syn) power, 16: window duration
#        ! FULL RECORD: 17: data power, 18: syn power, 19: (data-syn) power, 20: record duration
#        ! Example of a reduced file: awk '{print $2,$3,$4,$5,$6,$31,$32}' window_chi > window_chi_sub
 
mod=$1
band=$2
input=dT_${mod}_${band}.dat
output=dT_${mod}_${band}.ps
#cat ../../output/misfits/${mod}_${band}_*_chi |awk '{print $15,$19 }' >misfits_${mod}_${band}.dat
#cat window_chi |awk '{print a,$1,$15,$19,$13,$17}' a=$eid >> ../output/misfits/misfits_${mod}_${T}_BXZ.dat
cat /dev/null >$input
cat /dev/null >$input.all
for file in `ls ../../output/misfits/$mod/${mod}.set*_${band}_*_chi`;do
   echo $file
   evt=`echo $file |awk -F../../output/misfits/$mod/ '{print $2}' |awk -F_ '{print $4 }'`

   cat $file |awk '{print a,$1,$13,$17}' a=$evt >>$input.all
### MTTT
   cat $file |awk '{if($13!=0)print a,$1,$13,$17}' a=$evt >>$input
### XCTT
#   cat $file |awk '{print a,$1,$15,$19}' a=$evt >>$input.all
    cat $file |awk '{if($13==0&&$15!=0)print a,$1,$15,$19}' a=$evt >>$input
done 
nwin=`cat $input.all |wc -l`
nmeas=`cat $input |wc -l`
if [ $band == "T020_T050" ] || [ $band == "T005_T050" ];then
   psbasemap -JX9 -R-15/15/0/4000 -Ba5f2.5:"dT (s)":/a1000f500:"Num of Win":WSen -K -X4 -Y6 -P >$output
   ty=4300
   ty1=3800
   ty2=3500
else
   psbasemap -JX9 -R-15/15/0/8500 -Ba5f2.5:"dT (s)":/a1000f500:"Num of Win":WSen -K -X4 -Y6 -P >$output
   ty=9000
   ty1=8000
   ty2=7500
fi
a=`cat $input |awk '{print $3}' |awk 'BEGIN { sum=0;nn=0 } {sum = sum + $1; nn = nn+1} END { printf"%-8.2f\n", sum/nn }'`
b=`cat $input |awk '{print $3}' |awk -v avg=$a 'BEGIN { sum=0;nn=0 } {sum = sum + ($1-avg)*($1-avg); nn = nn+1} END { printf"%-8.2f\n", sqrt(sum/nn) }'`
cat $input |awk '{print $3}' |pshistogram -JX -R -S -W1.0 -L4.5p/green -F -G255/255/255 -O -K >>$output
cat $input |awk '{print $3}' |pshistogram -JX -R  -W1.0 -L0.5p/green -F -G255/255/255 -O -K >>$output


pstext -J -R -O -N <<eof >>$output
0.0 $ty 18 0.0 0 CM  ${mod} ${band}
-14.0 $ty1 12 0.0 0 LM nwin=$nwin nmeas=$nmeas
-14.0 $ty2 12 0.0 0 LM  Mean:$a std:$b
eof
rm $input $input.all
gs $output
