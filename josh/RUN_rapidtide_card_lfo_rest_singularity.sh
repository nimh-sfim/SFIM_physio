#!/bin/bash
# bash RUN_rapidtide_card_lfo_rest_singularity.sh
# for whatever reason, sbatch doesn't output stuff... BEWARE: sbatch --cpus-per-task=16 --mem=64g --time 60:00:00 RUN_rapidtide_card_lfo_rest_singularity.sh

#https://rapidtide.readthedocs.io/en/latest/usage_rapidtide.html
#The file you input here should be the result of any preprocessing you intend to do. The expectation is that rapidtide will be run 
#as the last preprocessing step before resting state or task based analysis
#Generally rapidtide is most useful for looking at low frequency oscillations, so when you run it, you usually use the --filterband lfo 
#option or some other to limit the analysis to the detection and removal of low frequency systemic physiological oscillations

SINGIMG=/data/SFIM_physio/mysing/my_rapidtide_image.img
ml singularity

for sbjid in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
#for sbjid in "11"; do

    the_directory_with_input_nii=/data/SFIM_physio/data/bp${sbjid}/func_rest
    name_of_input_nii=pb04.bp${sbjid}.r01.scale.nii
    the_directory_where_we_want_output=/data/SFIM_physio/data/derivatives/sub${sbjid}/rapidtide/cardiac_lfo10
    basename_you_want_for_rapidtide_output=sub${sbjid}_resting_card_lfo_delay_1030
    lfo_dir=/data/SFIM_physio/physio/physio_results/sub${sbjid}
    lfo_file=sub${sbjid}_lfo_downsampled2TR_arr_resting_hdr.tsv

    if [ -f ${the_directory_with_input_nii}/${name_of_input_nii} ]; then
        echo Processing $sbjid

        cmd="singularity run --cleanenv                                     \
                    -B ${the_directory_with_input_nii}/:/in                 \
                    -B ${lfo_dir}/:/in2                                     \
                    -B ${the_directory_where_we_want_output}:/out           \
                    ${SINGIMG}                                              \
                    rapidtide                                                   \
                        /in/${name_of_input_nii}                                \
                        /out/${basename_you_want_for_rapidtide_output}          \
                        --passes            1                                   \
                        --searchrange       -10 30                              \
                        --datatstep         0.75                                \
                        --oversampfac       5                                   \
                        --regressor         /in2/${lfo_file}                    \
                        --nprocs 3                                              \
                "
            echo $cmd       #state the command
            eval $cmd       #execute the command

    else
        echo $sbjid not found >> ${the_directory_where_we_want_output}/did-not-run.txt
    fi

done

