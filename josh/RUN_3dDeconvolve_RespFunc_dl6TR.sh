#!/bin/bash
# bash RUN_3dDeconvolve_RespFunc_dl6TR.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dDeconvolve_RespFunc_dl6TR.sh

# Currently have the flag -GOFORIT 4. I should not be using this though? Discuss the warnings / errors that I encounter. 

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do

    taskOI="resting"                #resting, inhold, outhold
    task4letters="rest"             #rest, binh, bouh
    delayrange_type="-9sto18s_dl6TR"

    fmri_data=/data/SFIM_physio/data/bp${sbjid}/func_${task4letters}/pb04.bp${sbjid}.r01.scale.nii
    MAP_mat=/data/SFIM_physio/physio/physio_results/sub${sbjid}/sub${sbjid}_MAP_lagged_mat_${taskOI}_-9sto18s_dl4.5s.tsv    #.tsv or .1D
    output_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/Resp_Func

    #If output directory is not present, make it
    if [ ! -d ${output_dir} ]
    then
        mkdir ${output_dir}
    fi

    cd ${output_dir}

    3dDeconvolve -input ${fmri_data}                                    \
        -num_stimts 7                                                   \
        -stim_file 1 "${MAP_mat}[0]" -stim_label 1 map_lag_regrs1       \
        -stim_file 2 "${MAP_mat}[1]" -stim_label 2 map_lag_regrs2       \
        -stim_file 3 "${MAP_mat}[2]" -stim_label 3 map_lag_regrs3       \
        -stim_file 4 "${MAP_mat}[3]" -stim_label 4 map_lag_regrs4       \
        -stim_file 5 "${MAP_mat}[4]" -stim_label 5 map_lag_regrs5       \
        -stim_file 6 "${MAP_mat}[5]" -stim_label 6 map_lag_regrs6       \
        -stim_file 7 "${MAP_mat}[6]" -stim_label 7 map_lag_regrs7       \
        -polort 1                                                           \
        -bucket ${sbjid}_${taskOI}_MAP_lagged_${delayrange_type}_stats      \
        -cbucket ${sbjid}_${taskOI}_MAP_lagged_${delayrange_type}_RespFunc  \
        -fout                                                               \
        -rout                                                               \
        -GOFORIT 4

done

