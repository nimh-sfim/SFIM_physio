#!/bin/bash
# bash RUN_rapidtide_bp_binh.sh

#https://rapidtide.readthedocs.io/en/latest/usage_rapidtide.html
#The file you input here should be the result of any preprocessing you intend to do. The expectation is that rapidtide will be run 
#as the last preprocessing step before resting state or task based analysis
#Generally rapidtide is most useful for looking at low frequency oscillations, so when you run it, you usually use the --filterband lfo 
#option or some other to limit the analysis to the detection and removal of low frequency systemic physiological oscillations

#################################
### Run the Rapidtide command ###
#################################

#sbjid="15"
#10 is already done
#"10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21"

#folder: blood_pressure is -8 to 8 searchrange with pass set to 1
#blood_pressure_old used argument delay_mapping (searchrange set to -10 30 and pass set to 3)
#blodd_pressure2 is -10 to 30 searchrange with pass set to 1
#11,15,18,20 for some reason didn't work?
#"11" "15" "18" "20"
#-8 8

# cd ../data/bp27/func_rest/
# 3dAFNItoNIFTI pb04.bp27.r01.scale*
# cd ../../../scripts/

# add "33" "34" once I get access to the fMRI data
#"10" "11" "12" "13" "14" "15" "16" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "30" "31" "32"
for sbjid in "26" "27" "28" "30" "31" "32" "33" "34"; do

    fmri_data=/data/SFIM_physio/data/bp${sbjid}/func_binh/pb04.bp${sbjid}.r01.scale.nii
    map_data=/data/SFIM_physio/physio/physio_results/sub${sbjid}/sub${sbjid}_MAP_downsampled2TR_arr_inhold.tsv
    out_prefix=sub${sbjid}_inhold_MAP_delay_20
    out_dir=/data/SFIM_physio/data/derivatives/sub${sbjid}/rapidtide/blood_pressure4
    cd ${out_dir}

    if [ -f ${fmri_data} ]; then
        echo Processing $sbjid

    rapidtide                               \
        ${fmri_data}                        \
        ${out_prefix}                       \
        --passes            1               \
        --searchrange       -20 20          \
        --datatstep         0.75            \
        --oversampfac       5               \
        --regressor         ${map_data}

    else
        echo $sbjid not found >> ${out_dir}/did-not-run.txt
    fi

done



#########################################################
### Miscellaneous notes that I should probably delete ###
#########################################################

#Not sure which voxels should be included in making the global regressor? --> no because using the MAP regressor as the probe regressor?
#-globalmeaninclude      "J:/ANVIL/Moyamoya/derivatives/trans/sub-01_T1w_bet_GMmask_0.75_run-1_scan-1_T1toFunc.nii.gz:1"     \
#-refineinclude         "other map"
#–globalmeaninclude: which voxels do we want to average over globally (we include avg signal in grey matter, and that’s the path!)
#–refineinclude: black box --> takes avg and reports correlation at each voxel
#NEVERMIND, THIS IS THE GM MASK!!!
#???

#Other notes of questionable choices
#    -passes                 3                                       \
#    -despecklepasses        4                                       \
#    -refineoffset           True                                    \
#    -doglmfilt              False                                   \
#    -searchrange            '-8 8'                                  \
#    -autosync                                                       \
#    -detrendorder           3                                       \      3 is already default
#    -spatialfilt           -1                                       \      -1 is already default
#    -filterband             'lfo'                                   \      'lfo' is already default
#    -pickleft                                                       \      is on by default
#    -outputlevel            ’normal’                                \
#    -nolimitoutput                                                  \
#    -offsettime???
