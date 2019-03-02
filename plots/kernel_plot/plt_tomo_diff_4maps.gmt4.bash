#!/bin/bash
module load gcc

gmtset MEASURE_UNIT cm
gmtset HEADER_FONT_SIZE 24p
gmtset BASEMAP_TYPE plain 
mod=TEN2TT
mod1=TT
indir=.
indir1=.
#tomo=grad.sum.${mod}.regridded.xyz
#tomo1=grad.sum.${mod1}.regridded.xyz

#tomo=CI.STC-TA.U11A.M21.$mod.beta_kernel.regridded.xyz
#tomo1=CI.STC-TA.U11A.M21.$mod1.beta_kernel.regridded.xyz
#tomodiff=CI.STC-TA.U11A.M21.${mod}-${mod1}.beta_kernel.regridded.xyz

tomo=CI.STC.M21.$mod.event_beta_kernel.regridded.xyz
tomo1=CI.STC.M21.$mod1.event_beta_kernel.regridded.xyz
tomodiff=CI.STC.M21.${mod}-${mod1}.event_beta_kernel.regridded.xyz

#PS=CI.STC.M21.TT.U11A_kernel_diff_${mod}_${mod1}.ps
PS=$tomodiff.ps
width=2.2
PROJ=M${width}i
tick=a2f1/a1
lonmin=-122.
lonmax=-114.
latmin=32.
latmax=37.
RMAP=$lonmin/$lonmax/$latmin/$latmax

# create color table for dvp
#CPT=vs.cpt
cmax=12
#$PDIR/svcpt <<! >> junk
#-$cmax $cmax
#!
#mv svel13.cpt $CPT
#makecpt -Cseis -T-$cmin/$cmax/0.2 -D >$CPT
# get xyz points form vtk file
i=1
for dep in 10 15 20 25 ;do
#for dep in 25 30 35 40 ;do
#for dep in `seq $3 5 $4` ;do
    echo $i
    z=`echo $dep |awk '{print -$1*1000}'`
    # slice 1
    cat $indir/$tomo |awk '{if($3==a&&$4!=-1000) print $1,$2,$4}' a=$z >$indir/dep$dep.xyz
    perl convert_utm2lonlat.pl $indir/dep$dep.xyz 11 > $indir/dep$dep.dat
    ref_vs=`cat $indir/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
    echo "tomo: $dep $ref_vs "
    #cat $indir/dep$dep.dat |awk '{print $1,$2,($3-a)/a*100}' a=$ref_vs >slow.slice1
    cat $indir/dep$dep.dat |awk '{print $1,$2,$3*10**14}' a=$ref_vs >slow.slice1
    blockmedian slow.slice1 -R$RMAP -I0.02 >slow.slice.m
    surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd.1
    #triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out
    rm dep$dep.xyz dep$dep.dat

    # slice 2
    cat $indir1/$tomo1 |awk '{if($3==a&&$4!=-1000) print $1,$2,$4}' a=$z >$indir1/dep$dep.xyz
    perl convert_utm2lonlat.pl $indir1/dep$dep.xyz 11 > $indir1/dep$dep.dat
    ref_vs1=`cat $indir1/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
    #cat $indir1/dep$dep.dat |awk '{print $1,$2,($3-a)/a*100}' a=$ref_vs >slow.slice2
    echo "tomo1: $dep $ref_vs1 "
    cat $indir1/dep$dep.dat |awk '{print $1,$2,$3*10**14}' a=$ref_vs >slow.slice2
    blockmedian slow.slice2 -R$RMAP -I0.02 >slow.slice.m
    surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd.2
    #triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out
    rm dep$dep.xyz dep$dep.dat

    # diff
    # slice 3
    cat $indir1/$tomodiff |awk '{if($3==a&&$4!=-1000) print $1,$2,$4}' a=$z >$indir1/dep$dep.xyz
    perl convert_utm2lonlat.pl $indir1/dep$dep.xyz 11 > $indir1/dep$dep.dat
    ref_vs1=`cat $indir1/dep$dep.dat |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
    #cat $indir1/dep$dep.dat |awk '{print $1,$2,($3-a)/a*100}' a=$ref_vs >slow.slice2
    echo "tomo1: $dep $ref_vs1 "
    cat $indir1/dep$dep.dat |awk '{print $1,$2,$3*10**14}' a=$ref_vs >slow.slice3
    blockmedian slow.slice3 -R$RMAP -I0.02 >slow.slice.m
    surface slow.slice.m -R$RMAP -I0.02 -Gslice.grd.3
    #triangulate slow.slice -R$RMAP -I0.25/0.25 -Gslice.grd -E > tria.out
    rm dep$dep.xyz dep$dep.dat


#    echo slow.slice2 > tempinp1
#    echo slow.slice1 >> tempinp1
#    echo slow.slice3 >> tempinp1
#   /home/l/liuqy/kai/progs/seistools/cal_xyz_diff_comp < tempinp1 >temp
#    ref_vs2=`cat slow.slice3 |awk 'BEGIN{sum=0.0;num=0} {{sum=sum+$3;num=num+1}} END{print sum/num}' a=$lonmin b=$lonmax c=$latmin d=$latmax`
#    echo "diff: $dep $ref_vs2"
#    awk -v a=${ref_vs} '{ print $1,$2,$3}' slow.slice3 | surface -Gslice.grd.3 -I0.02 -R$RMAP

    #grd2cpt slice.grd.3 -Cseis -S-12/12/0.1 -L-12/12 -D -Z > mydata.cpt
    #dvmax=`awk -v a=${ref_vs} '{ print $1,$2,sqrt($3*$3)}' slow.slice3 |minmax -C |awk '{print $6}'` 
    dvmax=1.2
    #makecpt -CWhite_Blue -T0/$dvmax/0.01 -D >dvs.cpt
    makecpt -Cseis -T-$dvmax/$dvmax/0.001 -D >dvs.cpt
    #makecpt -CRed_Yellow_White.cpt -T-$dvmax/0/0.01 -D >dvs.cpt
    
    # make cpt
#    vmin=`echo $ref_vs |awk '{print $1*(1-a/100) }' a=$cmax`
#    vmax=`echo $ref_vs |awk '{print $1*(1+a/100) }' a=$cmax`
#    echo "vel: $vmin $ref_vs $vmax"
    vmin=-$cmax
    vmax=$cmax
    makecpt -Cseis -T-$vmax/$vmax/0.01 -D >vs.cpt
    #makecpt -CRed_Yellow_White.cpt -T$vmax/$vmin/0.01 -D >vs.cpt
    
    for imap in 1 2 3;do
    if [ $imap -eq 1 -a $i -eq 1 ];then
       psbasemap -R$RMAP -J$PROJ -B"$tick"WesN -X1.5 -Y23 -K -P > $PS
    elif [ $imap -eq 1 -a $i -gt 1 ];then
       psbasemap -R$RMAP -J$PROJ -B"$tick"::Wens -X-4.9i -Y-6.5 -O -K >> $PS
    else
       psbasemap -R$RMAP -J$PROJ -B"$tick"::wens -X2.45i -O -K >> $PS
    fi
    if [ $imap -eq 3 ];then 
        CPT=dvs.cpt
    else 
        CPT=vs.cpt 
    fi
##### using ray density map to maks
#    cat $indir/raydensity.M21.regridded.xyz |awk '{if($3==a) print $1,$2,$4/1000}' a=$z >$indir/dep$dep.xyz
#    perl convert_utm2lonlat.pl $indir/dep$dep.xyz 11 > $indir/dep$dep.dat
#    cat $indir/dep$dep.dat |awk '{if($3*10**13>0.5) print $1,$2,1}' >mask.dat
#    rm dep$dep.xyz dep$dep.dat
#    psmask mask.dat -I0.02 -S0.06 -J -R -Ggray -O -K >>$PS
##
    grdimage slice.grd.$imap -J$PROJ -R$RMAP -C$CPT -B"$tick"::wens -Sl -O -K >> $PS
#    psmask -I0.02 -J -R -C -O -K >>$PS 

    #cat sources.dat |awk '{print $4,$3}' |psxy -J -R -St0.1 -O -K >>$PS
    #psxy jennings.xy -J -R -m -W0.2p,0/0/0 -O -K >> $PS
    pscoast -J -R  -O -K -W0.5p,black -Na/0.5p,black -Dh >> $PS
    if [ $imap -eq 1 ];then
    pstext -R -J -O -K -N <<EOF >> $PS
-121.6 32.6 12 0 1 ML $mod: $dep km
EOF
    elif [ $imap -eq 2 ];then
    pstext -R -J -O -K -N <<EOF >> $PS
-121.6 32.6 12 0 1 ML $mod1
EOF
    else
    pstext -R -J -O -K -N <<EOF >> $PS
-121.6 32.6 12 0 1 ML ${mod1}-$mod
EOF
    fi
    done # end loop of imap
    #
    dvstick=`echo $dvmax |awk '{printf"%.2f",$1/4}'`
    vstick=`echo $vmax $vmin |awk '{printf"%.1f",($1-$2)/8}'`
    psscale -D0.0i/-0.5/2.5i/0.3h -Cdvs.cpt -Ba${dvmax}/:"@~d@~K@-Vs@-x10@+-14@+m@+-3@+": -E -O -K -N >> $PS
    psscale -D-3.2i/-0.5/3.0i/0.3h -Cvs.cpt -Ba${vstick}/:"K@-Vs": -E -O -K -N >> $PS

#    if [ $i -eq 4 ];then
#    ### plot slice
#    psxy slice.dat -J -R -W1p,- -m -O -K >> $PS
#    cat slice.dat  |grep "^[^>]" |awk '{printf"%f %f 10 0 0 RT %s\n",$1,$2,$3}'  |pstext -J -R -W -O -K -N >> $PS
#    cat slice.dat  |grep "^[^>]" |awk '{printf"%f %f\n",$1,$2}'  |psxy -J -R -St0.1i -Wblack -Ggreen -O -K >> $PS
#    fi

   
    let i=i+1
done # end loop of depth 
cat /dev/null |psxy -J -R -Sc0.5i -O -N >>$PS
exit

