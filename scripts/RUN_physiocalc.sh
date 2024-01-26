#!/bin/bash
# bash RUN_physiocalc.sh
# cd /Users/deanjn/Documents/NIH/burak_phys
# Access biowulf via terminal: ssh deanjn@biowulf.nih.gov 

basedir=/Users/deanjn/Documents/NIH/burak_phys/physio_bids

## Change upon each iteration! 
sbjid=sub17
fileOI='Resting'   #Baseline, Binhold, BinholdBroken, BoutHold, Resting 
ntp=1200            #dset refers to MRI dataset! nt is number of MRI volumes
filt_freq=50
image_length=160
##

outbase=${basedir}/physio_results
inbase=${basedir}/physio_files/${sbjid}/test
phys_input=${inbase}/${sbjid}_${fileOI}_physio.tsv
json_input=${inbase}/${sbjid}_${fileOI}_physio.json
prefix_name=${sbjid}_${fileOI}
#The next three coding lines incorporate some feedback from Paul, re: using a variable for my output directory,
#using -p option so as not to throw an error if dir already exists, and "\" to the left of a command to make 
#the command *unaliased*, so as to I guess make commands run more predictably / consistently across devices / environments. This is good practice to do! 
#subject-level output dir
dir_subj=${outbase}/${sbjid}/test
\mkdir -p ${dir_subj}
cd ${dir_subj}

physio_calc.py                                                          \
    -phys_file          ${phys_input}                                   \
    -phys_json          ${json_input}                                   \
    -dset_nslice        1                                               \
    -dset_tr            0.75                                            \
    -dset_nt            ${ntp}                                          \
    -dset_slice_pattern alt+z                                           \
    -out_dir            ${outbase}/${sbjid}/test                        \
    -prefix             ${sbjid}                                        \
    -img_verb           3                                               \
    -verb               4                                               \
    -save_proc_peaks                                                    \
    -save_proc_troughs                                                  \
    -do_interact                                                        \
    -prefix             ${prefix_name}                                  \
    -prefilt_max_freq   ${filt_freq}                                    \
    -prefilt_mode       median                                          \
    -img_figsize        14 7                                            \
    -img_line_time      ${image_length}
