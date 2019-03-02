#!/bin/bash
gmtset MEASURE_UNIT cm
gmtset ANNOT_FONT_SIZE_PRIMARY 12p
gmtset LABEL_FONT_SIZE 2p
gmtset BASEMAP_TYPE plain 
indir=.
#kern=model.M16.regridded.xyz
#kern=output_m16_swap_regridded.xyz
#kern=raydensity.M21.regridded.xyz
#kern=model.M21.dlnvs_gaus.regridded.xyz
#kern=grad.prec.M21.regridded.xyz
#kern=Hdm_prec.gaus02.M21.regridded.xyz
#kern=Hdm.gaus02.p0.01.M21.regridded.xyz
kern=../model_plot/model.M21.dlnvs_gaus01_p0.04_r5.regridded.xyz
kern1=Hdm.gaus01_p0.04_r5.M21.regridded.xyz
PS=gaus01_p0.04_r5.ps
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
cmax=1.2
makecpt -CWhite_Blue.cpt -T0/$cmax/0.01 -D >$CPT
#makecpt -CRed_Yellow_White.cpt -T-$cmax/0/0.01 -D >$CPT

dep=15
z=`echo $dep |awk '{print -$1*1000}'`

cat $indir/$kern |awk '{if($3==a&&$4>-999) print $1,$2,$4}' a=$z >$indir/dep$dep.xyz
perl convert_utm2lonlat.pl $indir/dep$dep.xyz 11 > $indir/dep$dep.dat

ref_vs=`cat $indir/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
echo $dep $ref_vs
cat $indir/dep$dep.dat |awk '{print $1,$2,$3}' a=$ref_vs >slow.slice
cp slow.slice slow.slice.$dep
blockmedian slow.slice -R$RMAP -I0.02 >slow.slice.m
surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd
#xyz2grd slow.slice -R$RMAP -I0.02 -Gslice.grd
#triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out
psbasemap -R$RMAP -J$PROJ -B"$tick"::WenN -X4 -Y18 -K -P > $PS
grdimage slice.grd -J$PROJ -R$RMAP -C$CPT -B"$tick"::wens -O -K >> $PS
pscoast -J -R  -O -K -W1p,black -Na/1p,black -Dh >> $PS
pstext -R -J -O -K -N <<EOF >> $PS
-121.6 32.6 12 0 1 ML Depth $dep km
EOF
#psscale -D1.1i/-2/2.0i/0.3h -C$CPT -B"$cmax":"K@-vs@- ":/:: -E -O -K -N >> $PS
psscale -D2.6i/0.8i/1.2i/0.3 -C$CPT -B"$cmax"/:"dlnVs(%) ": -E -Al -O -K -N >> $PS
#############################3
# create color table for dvp
CPT=dvp.cpt
cmax=2.0
makecpt -CWhite_Blue.cpt -T0/$cmax/0.01 -D >$CPT
#makecpt -CRed_Yellow_White.cpt -T-$cmax/0/0.01 -D >$CPT


cat $indir/$kern1 |awk '{if($3==a&&$4>-999) print $1,$2,$4}' a=$z >$indir/dep$dep.xyz
perl convert_utm2lonlat.pl $indir/dep$dep.xyz 11 > $indir/dep$dep.dat

ref_vs=`cat $indir/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
echo $dep $ref_vs
cat $indir/dep$dep.dat |awk '{print $1,$2,$3*10**11}' a=$ref_vs >slow.slice
cp slow.slice slow.slice.$dep
blockmedian slow.slice -R$RMAP -I0.02 >slow.slice.m
surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd
#xyz2grd slow.slice -R$RMAP -I0.02 -Gslice.grd
#triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out
psbasemap -R$RMAP -J$PROJ -B"$tick"::weNs -X8.5 -O -K >> $PS
grdimage slice.grd -J$PROJ -R$RMAP -C$CPT -B"$tick"::wens -O -K >> $PS
pscoast -J -R  -O -K -W1p,black -Na/1p,black -Dh >> $PS
pstext -R -J -O -K -N <<EOF >> $PS
-121.6 32.6 12 0 1 ML Depth $dep km
EOF
#psscale -D1.1i/-2/2.0i/0.3h -C$CPT -B"$cmax":"K@-vs@-/10@+-12@+ m@+-3@+ ":/:: -E -O -N >> $PS
psscale -D2.6i/0.8i/1.2i/0.3 -C$CPT -B"$cmax"/:"Hdm(10@+-12@+) ": -E -O -N >> $PS


exit

