#!/bin/bash

for band in T008_T020 T015_T030 T020_T040;do
input1=misfits_M00_${band}_BXZ.dat
input2=misfits_M09_${band}_BXZ.dat
output=misfit_M00_M09_${band}.ps

psbasemap -JX9 -R-6/6/0/800 -Ba1f0.5:"dT(s)":/a100f25:"Num of Win":WSen -K -X4 -Y6 -P >$output
#---one
a1=`cat $input1 |awk '{print $3}' |awk 'BEGIN { sum=0;nn=0 } {sum = sum + $1; nn = nn+1} END { printf"%-8.2f\n", sum/nn }'`
b1=`cat $input1 |awk '{print $3}' |awk -v avg=$a1 'BEGIN { sum=0;nn=0 } {sum = sum + ($1-avg)*($1-avg); nn = nn+1} END { printf"%-8.2f\n", sqrt(sum/nn) }'`
cat $input1 |awk '{print $3}' |pshistogram -JX -R  -W0.5 -L0.5p/green -G255/255/255 -O -K >>$output
#---two
a2=`cat $input2 |awk '{print $3}' |awk 'BEGIN { sum=0;nn=0 } {sum = sum + $1; nn = nn+1} END { printf"%-8.2f\n", sum/nn }'`
b2=`cat $input2 |awk '{print $3}' |awk -v avg=$a2 'BEGIN { sum=0;nn=0 } {sum = sum + ($1-avg)*($1-avg); nn = nn+1} END { printf"%-8.2f\n", sqrt(sum/nn) }'`
cat $input2 |awk '{print $3}' |pshistogram -JX -R  -W0.5 -L0.5p/red -G255/255/255 -O -K >>$output
#---
cat $input1 |awk '{print $3}' |pshistogram -JX -R -S -W0.5 -L2.5p/green -G255/255/255 -O -K >>$output
cat $input2 |awk '{print $3}' |pshistogram -JX -R -S -W0.5 -L2.5p/red -G255/255/255 -O -K >>$output
pstext -J -R -O -N <<eof >>$output
0.0 750 12 0.0 0 CM $band
1.0 250 12 0.0 0 LM  M00:$a1\261$b1
1.0 220 12 0.0 0 LM  M09:$a2\261$b2

eof

#gs $output
done
