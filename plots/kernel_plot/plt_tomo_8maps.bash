#!/bin/bash
gmtset MEASURE_UNIT cm
gmtset HEADER_FONT_SIZE 24p
gmtset BASEMAP_TYPE plain 
indir=.
#kern=CI.STC.M21.TT.U11A_kernel.regridded.xyz
#kern=CI.STC.M21.TN.event_kernel.regridded.xyz
#kern=CI.STC-TA.U11A.M21.TEN2TT.beta_kernel.regridded.xyz
kern=CI.STC.M21.TEN2TT.event_beta_kernel.regridded.xyz
#kern=CI.STC.set15.M21.TT.kernel.regridded.xyz

PS=$indir/${kern}.ps
width=2.2
PROJ=M${width}i
tick=a2f1/a1
lonmin=-122.
lonmax=-114.
latmin=32.
latmax=37.
RMAP=$lonmin/$lonmax/$latmin/$latmax

# create color table for dvp
CPT=dvp.cpt
cmax=12.0
#$PDIR/svcpt <<! >> junk
#-$cmax $cmax
#!
#mv svel13.cpt $CPT
makecpt -Cseis -T-$cmax/$cmax/0.01 -D >$CPT

i=1
for dep in 5 10 15 20 25 30 35 45;do
    echo $i
    z=`echo $dep |awk '{print -$1*1000}'`
    cat $indir/$kern |awk '{if($3==a&&$4!=-1000) print $1,$2,$4}' a=$z >$indir/dep$dep.xyz
    perl convert_utm2lonlat.pl $indir/dep$dep.xyz 11 > $indir/dep$dep.dat

    ref_vs=`cat $indir/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
    echo $dep $ref_vs
    cat $indir/dep$dep.dat |awk '{print $1,$2,$3*10**14}' a=$ref_vs >slow.slice
    cp slow.slice slow.slice.$dep
    blockmedian slow.slice -R$RMAP -I0.02 >slow.slice.m
    surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd
    #xyz2grd slow.slice -R$RMAP -I0.02 -Gslice.grd
    #triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out

    if [ $i -le 4 ];then
    if [ $i -eq 1 ];then
    psbasemap -R$RMAP -J$PROJ -B"$tick"::WenN -X1.5 -Y13 -K > $PS
    elif [ $i -eq 4 ];then
    psbasemap -R$RMAP -J$PROJ -B"$tick"::wEnN -X7 -O -K >> $PS
    else
    psbasemap -R$RMAP -J$PROJ -B"$tick"::wenN -X7 -O -K >> $PS
    fi
    else
    if [ $i -eq 5 ];then
    psbasemap -R$RMAP -J$PROJ -B"$tick"::WenS -X-21 -Y-5.5 -O -K >> $PS
    elif [ $i -eq 8 ];then
    psbasemap -R$RMAP -J$PROJ -B"$tick"::wEnS -X7 -O -K >> $PS
    else
    psbasemap -R$RMAP -J$PROJ -B"$tick"::wenS -X7 -O -K >> $PS
    fi
    fi
#    if [ $i -gt 4 ];then
#    psmask mask.dat -I0.02 -J -R -Ggray -O -K >>$PS
#    fi
    grdimage slice.grd -J$PROJ -R$RMAP -C$CPT -B"$tick"::wens -O -K >> $PS
#    if [ $i -gt 4 ];then
#    psmask -I0.02 -J -R -C -O -K >>$PS
#    fi
#    psxy jennings.xy -J -R -m -W0.5p,0/0/0 -O -K >> $PS

    vstick=`echo $cmax |awk '{printf"%.f",$1/4}'`
    pscoast -J -R  -O -K -W1p,black -Na/1p,black -Dh >> $PS
pstext -R -J -O -K -N <<EOF >> $PS
-121 32.6 12 0 1 ML Depth $dep km
EOF

    tail -26 ../../src_rec/sources.dat |awk '{print $4,$3}' |psxy -J -R -St0.2 -O -K >>$PS
    let i=i+1
done 
psscale -D-7.5/-2/5i/0.3h -C$CPT -B"$vstick"::/:"K@-vs@-x10@+-14@+ m@+-3@+ ": -E -O -N >> $PS
exit

