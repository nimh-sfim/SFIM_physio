#!/bin/bash
# bash GLM_REML.sh
# cd /Users/deanjn/Documents/NIH/burak_phys
# Access biowulf via terminal: ssh deanjn@biowulf.nih.gov 
# This script uses pre-processed brain fMRI data and and creates a general linear model using AFNI.

#Check if the inputs are correct
if [ $# -ne 7 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the fMRI data you want to model"
  echo "Input 2 should be the demeaned motion parameters"
  echo "Input 3 should be the upper threshold ratio task regressor"
  echo "Input 4 should be the lower threshold ratio task regressor"
  echo "Input 5 should be the rvt regressor"
  echo "Input 6 should be the subject ID"
  echo "Input 7 should be the output directory"
  exit
fi

input_file="${1}"
motion_file="${2}"
upthres_ratio="${3}"
lowthres_ratio="${4}"
rvt_file="${5}"
sub_ID="${6}"
output_dir=${7}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_bucket.nii.gz" ]
then

  # Create design matrix using 3dDeconvolve
  3dDeconvolve -input ${input_file} -polort 4 -num_stimts 15        \
  -stim_file 1 "${motion_file}[0]" -stim_label 1 MotionRx           \
  -stim_file 2 "${motion_file}[1]" -stim_label 2 MotionRy           \
  -stim_file 3 "${motion_file}[2]" -stim_label 3 MotionRz           \
  -stim_file 4 "${motion_file}[3]" -stim_label 4 MotionTx           \
  -stim_file 5 "${motion_file}[4]" -stim_label 5 MotionTy           \
  -stim_file 6 "${motion_file}[5]" -stim_label 6 MotionTz           \
  -stim_file 7 "${motion_file}[6]" -stim_label 7 MotiondRx          \
  -stim_file 8 "${motion_file}[7]" -stim_label 8 MotiondRy          \
  -stim_file 9 "${motion_file}[8]" -stim_label 9 MotiondRz          \
  -stim_file 10 "${motion_file}[9]" -stim_label 10 MotiondTx        \
  -stim_file 11 "${motion_file}[10]" -stim_label 11 MotiondTy       \
  -stim_file 12 "${motion_file}[11]" -stim_label 12 MotiondTz       \
  -stim_file 13 "${upthres_ratio}" -stim_label 13 upthres_ratio     \
  -stim_file 14 "${lowthres_ratio}" -stim_label 14 lowthres_ratio   \
  -stim_file 15 "${rvt_file}" -stim_label 15 rvt                    \
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
