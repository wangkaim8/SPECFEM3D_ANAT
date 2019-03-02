#!/bin/bash
###
echo "convert topo data ..."
cp topo_bathy_final.dat topo.dat

###
echo "convert basement data ..."

#cat /dev/null >temp
#i=1
#for ix in `seq 1 1 161`;do
#  for iy in `seq 1 1 144`;do
#     cat reggridbase2_filtered_ascii.dat |awk '{if(NR==ind) print a,b,$1}' a=$ix b=$iy ind=$i >>temp 
#     let i=i+1
#  done
#done
#cat /dev/null >base.dat
#for iy in `seq 1 1 144`;do
#  for ix in `seq 1 1 161`;do
#     cat temp |awk '{if($1==a&&$2==b) print $3}' a=$ix b=$iy >>base.dat 
#  done
#done

###
echo "conver moho data ..."
cat /dev/null >moho.dat
for lat in `seq 32.0 0.1 37.0`;do
  for lon in `seq -121.0 0.1 -114`;do
     cat moho_lupei_zhu.dat |awk '{if($1==a&&$2==b) print -$3*1000}' a=$lon b=$lat >>moho.dat 
  done
done 
