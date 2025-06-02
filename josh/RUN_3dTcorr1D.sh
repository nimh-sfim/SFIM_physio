#!/bin/bash
# bash RUN_3dTcorr1D.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dTcorr1D.sh

# 3dTcorr1D if you want to correlate each voxel time series 
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

    MAP_1D=/data/SFIM_physio/physio/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_arr_${taskOI}_hdr.tsv
    output_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out
    fout_name_pearson=sub${sbjid}_Tcorr1D_pearson
    fout_name_fisher=sub${sbjid}_Tcorr1D_fisher

    #If output directory is not present, make it
    if [ ! -d ${output_dir} ]
    then
        mkdir ${output_dir}
    fi
    cd ${output_dir}

    # NO POLORT ARGUMENT!
    3dTcorr1D -pearson -prefix ${fout_name_pearson} ${fmri_data} ${MAP_1D}
    3dTcorr1D -Fisher -prefix ${fout_name_fisher} ${fmri_data} ${MAP_1D}

done

