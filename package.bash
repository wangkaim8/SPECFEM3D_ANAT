#!/bin/bash
# This script is used to package the whole inversion codes.
# Author: Kai Wang, wangkaim8@gmail.com
# University of Toronto, ON, Canada
# Last modified: Tue Dec 22 10:52:28 EDT 2017


out=ambient_noise_adjoint_tomography.package.SC.Rayl.SCINET
rm -rf $out
mkdir $out

cp -r ADJOINT_TOMOGRAPHY_TOOLS $out
#cp -r data $out
cp -r seis_process $out
cp -r src_rec $out
cp readme *.pl *.bash *.sh *.sandy *.gpc $out
mkdir -p $out/optimize
#cp optimize/*.bash $out/optimize
mkdir -p $out/specfem3d
cp -r specfem3d/bin $out/specfem3d
cp -r specfem3d/DATA $out/specfem3d
cp specfem3d/*.sh $out/specfem3d
mkdir $out/specfem3d/OUTPUT_FILES
mkdir $out/specfem3d/OUTPUT_FILES/DATABASES_MPI
mkdir $out/plots
mkdir $out/plots/kernel_plot
cp plots/kernel_plot/*.bash $out/plots/kernel_plot
cp plots/kernel_plot/*.csh $out/plots/kernel_plot
cp plots/kernel_plot/*.pl $out/plots/kernel_plot
mkdir $out/plots/model_plot 
cp plots/model_plot/*.bash $out/plots/model_plot
cp plots/model_plot/*.csh $out/plots/model_plot
cp plots/model_plot/*.pl $out/plots/model_plot
mkdir $out/plots/misfit_plot
cp plots/misfit_plot/*.bash $out/plots/misfit_plot
cp plots/misfit_plot/*.csh $out/plots/misfit_plot
mkdir $out/plots/seismo_plot
cp plots/seismo_plot/*.bash $out/plots/seismo_plot
cp plots/seismo_plot/*.csh $out/plots/seismo_plot
