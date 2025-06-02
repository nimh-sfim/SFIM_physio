#!/bin/bash
# bash RUN_3dDeconvolve_MAP1D.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dDeconvolve_MAP1D.sh

taskOI="outhold"                #resting, inhold, outhold
task4letters="bouh"             #rest, binh, bouh

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
#for sbjid in "10"; do

    fmri_data=/data/SFIM_physio/data/bp${sbjid}/func_${task4letters}/pb04.bp${sbjid}.r01.scale.nii
    MAP_1D=/data/SFIM_physio/physio/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_arr_${taskOI}_hdr.tsv
    output_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out

    #If output directory is not present, make it
    if [ ! -d ${output_dir} ]
    then
        mkdir ${output_dir}
    fi
    
    cd ${output_dir}

    3dDeconvolve -input ${fmri_data}                                    \
        -num_stimts 1                                                   \
        -stim_file 1 "${MAP_1D}[0]" -stim_label 1 map_regr_1D           \
        -polort 1                                                       \
        -bucket sub${sbjid}_${taskOI}_MAP1D_stats                       \
        -cbucket sub${sbjid}_${taskOI}_MAP1D_coeff                      \
        -fout                                                           \
        -rout

done

#-GOFORIT 4
