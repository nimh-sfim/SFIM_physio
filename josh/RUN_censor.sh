#!/bin/bash
# bash RUN_censor.sh

# This script generates the boxcar design indicating regions that must be censored in the PPG trace.
# Please understand that I've decimated the PPG signal first by a factor of 50 using convert_ppg2txt.m...
# Will have to upsample back up when loading in to MATLAB again.

taskOI="outhold"    #resting, inhold, outhold
subject_list=("29")
#subject_list=("11" "12" "13" "14" "15" "16" "18" "19" "20" "21" "22" "23" "24" "25" "27" "28" "30" "31" "32" "33" "34")

for sbjid in ${subject_list[@]}; do

    echo "${subject_list[@]}"

    dir="/data/SFIM_physio/physio/physio_results/sub${sbjid}/"
    #dir="/data/SFIM_physio/scripts/josh/"
    cd ${dir}
    cat sub${sbjid}_${taskOI}_ppg.txt > sub${sbjid}_${taskOI}_ppg.1D               #Convert .txt to .1D
    1dtranspose sub${sbjid}_${taskOI}_ppg.1D  > sub${sbjid}_${taskOI}_ppg_T.1D      #Make sure it's a row vector
    3dToutcount sub${sbjid}_${taskOI}_ppg_T.1D > sub${sbjid}_${taskOI}_censor.1D    #Determine where to censor
    1dplot sub${sbjid}_${taskOI}_censor.1D

done
