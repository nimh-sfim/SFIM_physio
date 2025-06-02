#!/bin/bash
# bash RUN_3dcalc_regress_fitted_mapts.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dcalc_regress_fitted_mapts.sh

taskOI="outhold"                #resting, inhold, outhold
task4letters="bouh"             #rest, binh, bouh

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
#for sbjid in "14"; do

    dir1="/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out"
    dir2="/data/SFIM_physio/data/derivatives/sub${sbjid}/Resp_Func"

    fmri_data_detrended=${dir1}/pb04.bp${sbjid}_${taskOI}_detrended2.nii
    MAP1D_same_across_all_voxels=${dir1}/${sbjid}_${taskOI}_MAP1D_same_voxelwise.nii
    Convolved_MAPxRF_timeseries=${dir2}/${sbjid}_${taskOI}_MAP_lagged_-9sto18s_dl4TR_MAPRF_voxelwise.nii
    MAPxRF_fitts=${dir1}/sub${sbjid}_Tcorr_ycoef.nii
    MAP1D_fitts=${dir1}/sub${sbjid}_${taskOI}_MAP1D_coeff.nii   #are there multiple sub-bricks???

    # If output directory is not present, make it
    if [ ! -d ${dir1} ]
    then
        mkdir ${dir1}
    fi
    cd ${dir1}

    # Now that I have fit coefficients for voxelwise convolved MAPxRF (which are the Tcorr_ycoef outputs) as well as MAP1D (in *MAP1D_coeff outputs), 
    # let's regress these out to create new denoised NIFTIs

    # Considering the response function results
    3dcalc -a ${fmri_data_detrended} -b ${Convolved_MAPxRF_timeseries} -c ${MAPxRF_fitts} -prefix sub${sbjid}_${taskOI}_denoised_data_MAPxRF.nii -expr 'a-c*b'

    # Not considering the response function results
    3dcalc -a ${fmri_data_detrended} -b ${MAP1D_same_across_all_voxels} -c ${MAP1D_fitts}'[2]' -prefix sub${sbjid}_${taskOI}_denoised_data_MAP1D.nii -expr 'a-c*b'

    #"${MAP_mat}[0]"

done

