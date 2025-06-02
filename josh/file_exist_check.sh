#!/bin/bash
# bash file_exist_check.sh

subject_list=("10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "30" "31" "32" "33" "34")
echo "Subject list..." > file_exist_check.txt
echo "${subject_list[@]}" >> file_exist_check.txt

#for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "30" "31" "32" "33" "34"; do
#for sbjid in "12" "13"; do

for sbjid in ${subject_list[@]}; do

    echo '************************' >> file_exist_check.txt
    echo sub$sbjid >> file_exist_check.txt
    echo '************************' >> file_exist_check.txt

    ########################
    ### Define filenames ###
    ########################
    # Directories
    dir_physio="/data/SFIM_physio/physio"
    rapidtide_lfo_dir="/data/SFIM_physio/data/derivatives/sub${sbjid}/rapidtide/cardiac_lfo10"
    rapidtide_MAP_dir="/data/SFIM_physio/data/derivatives/sub${sbjid}/rapidtide/blood_pressure10"
    # # ACQ data
    # inhold_input="${dir_physio}/physio_files/sub${sbjid}/sub${sbjid}_inhold_physio.tsv"
    # outhold_input="${dir_physio}/physio_files/sub${sbjid}/sub${sbjid}_outhold_physio.tsv"
    # resting_input="${dir_physio}/physio_files/sub${sbjid}/sub${sbjid}_resting_physio.tsv"
    # # MAP downsampled to TR
    # inhold_MAP_TR="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_inhold.tsv"
    # outhold_MAP_TR="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_outhold.tsv"
    # resting_MAP_TR="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_resting.tsv"
    # # Resp peaks
    # inhold_resp="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_inhold_resp_peaks_00.1D"
    # outhold_resp="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_outhold_resp_peaks_00.1D"
    # resting_resp="${dir_physio}/physio_results/sub${sbjid}/sub${sbjid}_resting_resp_peaks_00.1D"
    # # fMRI input data
    # fmri_resting="/data/SFIM_physio/data/bp${sbjid}/func_rest/pb04.bp${sbjid}.r01.scale.ni*"
    # fmri_inhold="/data/SFIM_physio/data/bp${sbjid}/func_binh/pb04.bp${sbjid}.r01.scale.ni*"
    # fmri_outhold="/data/SFIM_physio/data/bp${sbjid}/func_bouh/pb04.bp${sbjid}.r01.scale.ni*"
    # Rapidtide
    inhold_lfo_rapidtide_20="${rapidtide_lfo_dir}/sub${sbjid}_inhold_card_lfo_delay_1030_desc-maxtime_map.ni*"
    outhold_lfo_rapidtide_20="${rapidtide_lfo_dir}/sub${sbjid}_outhold_card_lfo_delay_1030_desc-maxtime_map.ni*"
    resting_lfo_rapidtide_20="${rapidtide_lfo_dir}/sub${sbjid}_resting_card_lfo_delay_1030_desc-maxtime_map.ni*"
    inhold_MAP_rapidtide_20="${rapidtide_MAP_dir}/sub${sbjid}_inhold_MAP_delay_1030_desc-maxtime_map.ni*"
    outhold_MAP_rapidtide_20="${rapidtide_MAP_dir}/sub${sbjid}_outhold_MAP_delay_1030_desc-maxtime_map.ni*"
    resting_MAP_rapidtide_20="${rapidtide_MAP_dir}/sub${sbjid}_resting_MAP_delay_1030_desc-maxtime_map.ni*"

    #file_list=(${inhold_input} ${outhold_input} ${resting_input} ${inhold_MAP_TR} ${outhold_MAP_TR} ${resting_MAP_TR} ${inhold_resp} ${outhold_resp} ${resting_resp} ${fmri_resting} ${fmri_inhold} ${fmri_outhold} ${inhold_lfo_rapidtide_10} ${outhold_lfo_rapidtide_10} ${resting_lfo_rapidtide_10} ${inhold_MAP_rapidtide_10} ${outhold_MAP_rapidtide_10} ${resting_MAP_rapidtide_10} ${inhold_lfo_rapidtide_20} ${outhold_lfo_rapidtide_20} ${resting_lfo_rapidtide_20} ${inhold_MAP_rapidtide_20} ${outhold_MAP_rapidtide_20} ${resting_MAP_rapidtide_20})
    
    #file_list=(${inhold_lfo_rapidtide_20} ${outhold_lfo_rapidtide_20} ${resting_lfo_rapidtide_20} ${inhold_MAP_rapidtide_20} ${outhold_MAP_rapidtide_20} ${resting_MAP_rapidtide_20})
    
    file_list=(${inhold_lfo_rapidtide_20} ${outhold_lfo_rapidtide_20} ${inhold_MAP_rapidtide_20} ${outhold_MAP_rapidtide_20})
    #file_list=(${resting_MAP_rapidtide_20})

    #######################
    ### Run the command ###
    #######################

    for file in "${file_list[@]}"; do
        if [ -f "$file" ]; then
            #echo "File '$file' exists."
            true
        else
            echo "File '$file' does not exist." >> file_exist_check.txt
        fi
    done
    
done

