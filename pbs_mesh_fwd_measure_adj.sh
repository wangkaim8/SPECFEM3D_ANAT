 #!/bin/bash

#PBS -N FWD.M00.set1
#PBS -M kai.wang@mq.edu.au
#PBS -m abe
#PBS -l nodes=21:ppn=8
#PBS -l walltime=04:30:00



# script runs mesher,database generation and solver
# using this example setup
#
prog=~/progs/specfem3d
###################################################
module load intel/15.0.2 openmpi/intel/1.6.4
#=====
cd $PBS_O_WORKDIR
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/intel/lib/intel64:/usr/local/openmpi/lib
#=====
cdir=`pwd`
# number of processes
NPROC=168
mod=M00.set1
is_ls=false
srfile=sources_set1.dat
####
nevt=`cat src_rec/$srfile |wc -l`
echo $nevt "found!!!"
for evtnum in `seq 1 1 $nevt`;do # loop over all virtual evts
evtfile=`cat src_rec/$srfile |sed -n "${evtnum}p"`
eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
fwd_dir=solver/$mod/$eid

echo $eid


cd $fwd_dir  
# number of processes
NPROC=`grep ^NPROC DATA/Par_file | cut -d = -f 2`

# decomposes mesh
date
echo
echo "running mesher..."
echo
mpirun -np $NPROC ./bin/xmeshfem3D
#mv OUTPUT_FILES/output_mesher.txt OUTPUT_FILES/output_meshfem3D.txt
# runs database generation
echo
echo "running database generation..."
echo
mpirun -np $NPROC ./bin/xgenerate_databases
date
echo "Mesh done!!!"
# simulation part
#
cp $prog/utils/change_simulation_type.pl .
./change_simulation_type.pl -F
# runs simulation
date
echo
echo "running solver (forward)..."
echo
mpirun -np $NPROC ./bin/xspecfem3D
# sleep 1200

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
date

echo "rename *.semd timestamp*"
rename timestamp timestamp_fwd OUTPUT_FILES/timestamp*
rename .semd .fwd.semd OUTPUT_FILES/*.semd
if $is_ls;then
   rm -rf OUTPUT_FILES/DATABASES_MPI
fi
cd $cdir
###
done # end loop of evt
echo "Forward simultiton finished!"
date


# Turn off implicit threading in Python, R
export OMP_NUM_THREADS=1
module load use.own 
module load sac101.6a
module load gcc
module load gnu-parallel/20150822

date
nsta=`cat src_rec/$srfile |wc -l`
echo "preprocessing ..."
cd seis_process_$mod
# START PARALLEL JOBS USING NODE LIST IN $PBS_NODEFILE
seq $nsta | parallel -j8 --sshloginfile $PBS_NODEFILE --workdir $PWD ./run {}
cd ..
date
echo "meas_adj ..."
cd measure_adj_$mod

seq $nsta | parallel -j8 --sshloginfile $PBS_NODEFILE --workdir $PWD ./run {}
date
#=====
cd $cdir
nevt=`cat src_rec/$srfile |wc -l`
for evtnum in `seq 1 1 $nevt`;do # loop over all virtual evts
evtfile=`cat src_rec/$srfile |sed -n "${evtnum}p"`

eid=`echo $evtfile |awk '{printf"%s.%s",$2,$1}'`
fwd_dir=solver/$mod/$eid
echo $eid
#-------------
cd $fwd_dir

./change_simulation_type.pl -b
date
echo
echo "running solver (adjoint) ..."
echo
mpirun -np $NPROC ./bin/xspecfem3D

echo
echo "see results in directory: OUTPUT_FILES/"
echo
#---delete outputfiles
if [ -f OUTPUT_FILES/timestamp024000 ];then
basedir=OUTPUT_FILES/DATABASES_MPI
rm -rf SEM
rm OUTPUT_FILES/*.semd
rm -rf $basedir/*external_mesh.bin
rm -rf $basedir/*Database
rm -rf $basedir/*save_forward_arrays.bin
rm -rf $basedir/*absorb_field.bin
fi
cd $cdir
done



