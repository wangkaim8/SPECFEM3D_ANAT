#!/bin/bash
prog=~/progs/Visualization/sph2utm_Qinya_Liu

#echo "conver topo data ..."
#cat /dev/null > topo.geo
#i=1
#for iy in `seq 1 1 1001`;do
#  for ix in `seq 1 1 1401`;do
#      lon=`echo "-121.0+($ix-1)*0.005" |bc -l`
#      lat=`echo "32.0+($iy-1)*0.005" |bc -l`
#     cat topo_bathy_final.dat |awk '{if(NR==ind) print a,b,$1}' a=$lon b=$lat ind=$i >>topo.geo 
#     let i=i+1
#  done
#done

exit

cat /dev/null >base.geo
i=1
for ix in `seq 1 1 161`;do
  for iy in `seq 1 1 144`;do
      x=`echo "316000+($ix-1)*1000" |bc -l`
      y=`echo "3655000+($iy-1)*1000" |bc -l`
      lon=`echo $x $y |$prog/utm2sph |tail -1 |awk '{print $3}'`
      lat=`echo $x $y |$prog/utm2sph |tail -1 |awk '{print $6}'`
     cat reggridbase2_filtered_ascii.dat |awk '{if(NR==ind) print a,b,-$1}' a=$lon b=$lat ind=$i >>base.geo 
     let i=i+1
  done
done

###
echo "conver moho data ..."
cat /dev/null >moho.geo
for lat in `seq 32.0 0.1 37.0`;do
  for lon in `seq -121.0 0.1 -114`;do
     cat moho_lupei_zhu.dat |awk '{if($1==a&&$2==b) print $1,$2,$3}' a=$lon b=$lat >>moho.geo 
  done
done
