#!/bin/bash
# bash GLM_REML.sh
# cd /Users/deanjn/Documents/NIH/burak_phys
# Access biowulf via terminal: ssh deanjn@biowulf.nih.gov 
# This script uses pre-processed brain fMRI data and and creates a general linear model using AFNI.

#Check if the inputs are correct
if [ $# -ne 4 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the fMRI data you want to model"
  echo "Input 2 should be the ratio task regressor"
  echo "Input 3 should be the subject ID"
  echo "Input 4 should be the output directory"
  exit
fi

input_file="${1}"
ratio_file="${2}"
sub_ID="${3}"
output_dir=${4}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_bucket.nii.gz" ]
then

  # Create design matrix using 3dDeconvolve
  3dDeconvolve -input ${input_file} -polort 4 -num_stimts 1         \
  -stim_file 1 "${ratio_file}" -stim_label 1 ratio                  \
  -x1D ${output_dir}/"${sub_ID}_matrix.1D" -x1D_stop

  # Run GLM using 3dREMLfit
  3dREMLfit -input ${input_file}                                    \
    -matrix ${output_dir}/"${sub_ID}_matrix.1D"                     \
    -tout -rout                                                     \
    -Rbeta ${output_dir}/"${sub_ID}_bcoef.nii.gz"                   \
    -Rbuck ${output_dir}/"${sub_ID}_bucket.nii.gz"                  \
    -Rfitts ${output_dir}/"${sub_ID}_fitts.nii.gz"                  \
    -Rerrts ${output_dir}/"${sub_ID}_errts.nii.gz"

else
  echo "** ALREADY RUN: subject=${sub_ID} **"
fi
