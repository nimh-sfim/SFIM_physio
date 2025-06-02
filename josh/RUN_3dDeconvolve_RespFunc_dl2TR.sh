#!/bin/bash
# bash RUN_3dDeconvolve_RespFunc_dl2TR.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dDeconvolve_RespFunc_dl2TR.sh

# Currently have the flag -GOFORIT 4. I should not be using this though? Discuss the warnings / errors that I encounter. 

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do

    taskOI="resting"                #resting, inhold, outhold
    task4letters="rest"             #rest, binh, bouh
    delayrange_type="-9sto18s_dl2TR"

    fmri_data=/data/SFIM_physio/data/bp${sbjid}/func_${task4letters}/pb04.bp${sbjid}.r01.scale.nii
    MAP_mat=/data/SFIM_physio/physio/physio_results/sub${sbjid}/sub${sbjid}_MAP_lagged_mat_${taskOI}_-9sto18s_dl1.5s.tsv    #.tsv or .1D
    output_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/Resp_Func

    #If output directory is not present, make it
    if [ ! -d ${output_dir} ]
    then
        mkdir ${output_dir}
    fi

    cd ${output_dir}

    3dDeconvolve -input ${fmri_data}                                    \
        -num_stimts 19                                                  \
        -stim_file 1 "${MAP_mat}[0]" -stim_label 1 map_lag_regrs1       \
        -stim_file 2 "${MAP_mat}[1]" -stim_label 2 map_lag_regrs2       \
        -stim_file 3 "${MAP_mat}[2]" -stim_label 3 map_lag_regrs3       \
        -stim_file 4 "${MAP_mat}[3]" -stim_label 4 map_lag_regrs4       \
        -stim_file 5 "${MAP_mat}[4]" -stim_label 5 map_lag_regrs5       \
        -stim_file 6 "${MAP_mat}[5]" -stim_label 6 map_lag_regrs6       \
        -stim_file 7 "${MAP_mat}[6]" -stim_label 7 map_lag_regrs7       \
        -stim_file 8 "${MAP_mat}[7]" -stim_label 8 map_lag_regrs8       \
        -stim_file 9 "${MAP_mat}[8]" -stim_label 9 map_lag_regrs9       \
        -stim_file 10 "${MAP_mat}[9]" -stim_label 10 map_lag_regrs10       \
        -stim_file 11 "${MAP_mat}[10]" -stim_label 11 map_lag_regrs11       \
        -stim_file 12 "${MAP_mat}[11]" -stim_label 12 map_lag_regrs12       \
        -stim_file 13 "${MAP_mat}[12]" -stim_label 13 map_lag_regrs13       \
        -stim_file 14 "${MAP_mat}[13]" -stim_label 14 map_lag_regrs14       \
        -stim_file 15 "${MAP_mat}[14]" -stim_label 15 map_lag_regrs15       \
        -stim_file 16 "${MAP_mat}[15]" -stim_label 16 map_lag_regrs16       \
        -stim_file 17 "${MAP_mat}[16]" -stim_label 17 map_lag_regrs17       \
        -stim_file 18 "${MAP_mat}[17]" -stim_label 18 map_lag_regrs18       \
        -stim_file 19 "${MAP_mat}[18]" -stim_label 19 map_lag_regrs19       \
        -polort 1                                                           \
        -bucket ${sbjid}_${taskOI}_MAP_lagged_${delayrange_type}_stats      \
        -cbucket ${sbjid}_${taskOI}_MAP_lagged_${delayrange_type}_RespFunc  \
        -fout                                                               \
        -rout                                                               \
        -GOFORIT 4

done

