#!/bin/bash
# bash RUN_3dDetrend.sh
# sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_3dDetrend.sh

taskOI="outhold"                #resting, inhold, outhold
task4letters="bouh"             #rest, binh, bouh

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
#for sbjid in "10"; do

    dir1="/data/SFIM_physio/data/derivatives/sub${sbjid}/func_${task4letters}_MAPRF_out"
    dir2="/data/SFIM_physio/data/bp${sbjid}/func_${task4letters}"

    input_dset=${dir2}/pb04.bp${sbjid}.r01.scale.nii
    fileout_name=pb04.bp${sbjid}_${taskOI}_detrended2.nii
    
    # If output directory is not present, make it
    if [ ! -d ${dir1} ]
    then
        mkdir ${dir1}
    fi
    cd ${dir1}

    3dDetrend -prefix ${fileout_name} -session ${dir1} -polort 1 ${input_dset}

done

