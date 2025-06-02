#!/bin/bash
# bash RUN_3dTcorrelate.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dTcorrelate.sh

# for regressing MAP timeseries, not convolved with RF... use 3dTcorr1D
# Also see 3dTcorr1D if you want to correlate each voxel time series 
# in a dataset xset with a single 1D time series file, instead of 
# separately with time series from another 3D+time dataset.

taskOI="outhold"                #resting, inhold, outhold
task4letters="bouh"             #rest, binh, bouh

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
#for sbjid in "14"; do

    dir1="/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out"
    input_name=pb04.bp${sbjid}_${taskOI}_detrended2.nii
    #fmri_data=/data/SFIM_physio/data/bp${sbjid}/func_${task4letters}/pb04.bp${sbjid}.r01.scale.nii
    fmri_data=${dir1}/${input_name}

    MAP_mat=/data/SFIM_physio/data/derivatives/sub${sbjid}/Resp_Func/${sbjid}_${taskOI}_MAP_lagged_-9sto18s_dl4TR_MAPRF_voxelwise.nii
    output_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out
    fout_name=sub${sbjid}_Tcorr
    fout_name_pearson=sub${sbjid}_Tcorr_pearson
    fout_name_covariance=sub${sbjid}_Tcorr_covariance
    fout_name_ycoef=sub${sbjid}_Tcorr_ycoef
    fout_name_fisher=sub${sbjid}_Tcorr_fisher

    #If output directory is not present, make it
    if [ ! -d ${output_dir} ]
    then
        mkdir ${output_dir}
    fi
    cd ${output_dir}

    3dTcorrelate -pearson -polort 1 -prefix ${fout_name_pearson} ${fmri_data} ${MAP_mat}
    3dTcorrelate -covariance -polort 1 -prefix ${fout_name_covariance} ${fmri_data} ${MAP_mat}
    3dTcorrelate -ycoef -polort 1 -prefix ${fout_name_ycoef} ${fmri_data} ${MAP_mat}
    3dTcorrelate -Fisher -polort 1 -prefix ${fout_name_fisher} ${fmri_data} ${MAP_mat}
    # 3dTcorrelate -pearson -covariance -ycoef -Fisher -polort 1 -prefix ${fout_name} ${fmri_data} ${MAP_mat}

    # 3dTcorrelate                            \
    #     -pearson                            \
    #     -covariance                         \
    #     -ycoef                              \
    #     -Fisher                             \
    #     -polort 1                           \
    #     -prefix ${fout_name}                \
    #     ${fmri_data} ${MAP_mat}

done

