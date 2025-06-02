#!/bin/bash
# bash /Volumes/SFIM_physio/scripts/josh/RUN_3dresample.sh
# bash /data/SFIM_physio/scripts/josh/RUN_3dresample.sh
# bash RUN_3dresample.sh

# Resample fMRI data to be same number of elements in the matrix to atlases of interest

# https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dresample.html 
# 3dresample -master master+orig -prefix new.dset -input old+orig -rmode NN
# NN doesn't give fractions
# afni 3dresample
# master is fmri data working with
# input is atlas

parent_dir=/data/SFIM_physio
master=${parent_dir}/data/bp18/func_rest/pb04.bp18.r01.scale.nii
filename="aparc.a2009s+aseg_REN_gm"         #fs_ap_wm, fs_ap_latvent, aparc.a2009s+aseg_REN_wmat, aparc.a2009s+aseg_REN_vent, aparc.a2009s+aseg_REN_gm
old=${parent_dir}/atlases_rs/suma_MNI152_2009/${filename}.nii.gz
OUT_DSET=${parent_dir}/atlases_rs/${filename}_rs

3dresample -master ${master} -prefix ${OUT_DSET} -input ${old} -rmode NN

cd ${parent_dir}/atlases_rs
3dAFNItoNIFTI ${OUT_DSET}+tlrc
