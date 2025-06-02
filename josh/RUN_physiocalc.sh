#!/bin/bash
# bash RUN_physiocalc.sh

###########################################
### Define filenames and dset_nt inputs ###
###########################################

# Issues that came across:
# sub12 outhold and inhold resp is digitized like crazy
# sub26 outhold resp is shorter than scan length
# sub26 inhold .tsv doesn't exist
# sub11 inhold is too short.
# sub23 inhold resp looks very bad. belt not tight enough?

#'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34']
sbjid=34
ntp=1600             #dset refers to MRI dataset! nt is number of MRI volumes. ntp can be found in column B here: 
                    #https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit?usp=sharing
fileOI="resting"    #Baseline, Binhold, BinholdBroken, BoutHold, Resting 
taskOI_fourletters="rest"   #rest, binh, bouh
filt_freq=200

# if sbjid == "11" && strncmp(taskOI,'rest',4)
#     nvols = 586;
# elseif sbjid == "11" && strncmp(taskOI,'inhold',4)
#     nvols = 586;

######################################
## Setup the physio_calc.py command ##
######################################

basedir="/data/SFIM_physio/physio"
outbase=${basedir}/physio_results/sub${sbjid}
inbase=${basedir}/physio_files/sub${sbjid}
phys_input=${inbase}/sub${sbjid}_${fileOI}_physio.tsv
json_input=${inbase}/sub${sbjid}_${fileOI}_physio.json
prefix_name=sub${sbjid}_${fileOI}
LOAD_PROC_PEAKS_RESP=${outbase}/sub${sbjid}_${fileOI}_resp_peaks_00.1D
LOAD_PROC_TROUGHS_RESP=${outbase}/sub${sbjid}_${fileOI}_resp_troughs_00.1D

echo '************************'
echo sub$sbjid
echo '************************'

dir_subj=${outbase}         #subject-level output dir
\mkdir -p ${dir_subj}       #re: feedback from Paul, using -p option so as not to throw an error if dir already exists, and "\" to the left of a command to make the command *unaliased*, so as to I guess make commands run more predictably / consistently across devices / environments. This is good practice to do! 
cd ${dir_subj}

DO_EPI=1
dset_epi_dir="/data/SFIM_physio/data"
if [ "${DO_EPI}" -eq 1 ]; then
    #fmri_file=${dset_epi_dir}/bp${sbjid}/func_bouh/pb03.bp${sbjid}.r01.volreg.nii
    fmri_file=${dset_epi_dir}/bp${sbjid}/func_${taskOI_fourletters}/pb03.bp${sbjid}.r01.volreg+tlrc.BRIK
    MRI_metrics="-dset_epi ${fmri_file}"
    if [ -f $fmri_file ]; then
        echo "File $fmri_file exists."
        echo "so DO_EPI probably worked!"
    else
        echo "File $fmri_file does NOT exist."
        echo "so DO_EPI probably did not work..."
    fi
else
    MRI_metrics="-dset_nslice 1 -dset_tr 0.75 -dset_nt ${ntp} -dset_slice_pattern alt+z"
    echo "EPI file was not successfully provided."
fi

######################################
### Run the physio_calc.py command ###
######################################

physio_calc.py                                                          \
    -phys_file          ${phys_input}                                   \
    -phys_json          ${json_input}                                   \
    ${MRI_metrics}                                                      \
    -out_dir            ${outbase}                                      \
    -prefix             ${prefix_name}                                  \
    -img_verb           1                                               \
    -verb               2                                               \
    -load_proc_peaks_resp       ${LOAD_PROC_PEAKS_RESP}                 \
    -load_proc_troughs_resp     ${LOAD_PROC_TROUGHS_RESP}               \
    -save_proc_peaks                                                    \
    -save_proc_troughs                                                  \
    -no_card_out                                                        \
    -prefilt_max_freq   ${filt_freq}                                    \
    -prefilt_mode       median                                          \
    -img_line_time      120                                             \
    -do_interact


#    -img_figsize        14 7                                            \
