#!/bin/bash
# bash Group_3dttest_testing.sh
# This script runs group-level analysis

parent_dir="/data/SFIM_physio"
input_prefix="/data/SFIM_physio/data/derivatives"
output_dir="/data/SFIM_physio/data/derivatives/group"
phys_type="rapidtide"

DO_group=1        # this may be the only one that works?
DO_Threshold=0    # not sure anything here or below works for 3dttest
DO_use_afc=0
DO_Cluster=0
DO_mask=0

if [ "${DO_group}" -eq 1 ]
then
  echo "******************"
  echo "Group activation"
  echo "******************"

  run3dttest="3dttest++ -prefix ${input_prefix}/group/group_${phys_type} "
  run3dttest="${run3dttest} -setA SETNAME"

  for subject in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do

    bcoef="${input_prefix}/sub${subject}/rapidtide/sub${subject}_resting_MAP_delay_desc-maxtime_map.nii.gz"
    
    run3dttest="${run3dttest} ${subject} ${bcoef}"
    
    echo ${subject}_${phys_type} "This dataset has made it to the important part of the loop -- YAYYYY"

  done

  #run3dttest="${run3dttest} -max_zeros 0.25 -model_outliers"
  #run3dttest="${run3dttest} -mask ${input_prefix}/MNI152_T1_2mm_brain.nii.gz"  # <-- don't want to mask because potentially want to look at draining veins
  eval ${run3dttest}

else
  echo "*****************************"
  echo "Not doing Group activation"
  echo "*****************************"
fi


##############################################################################################################


if [ "${DO_Threshold}" -eq 1 ]
then
    echo "*****************"
    echo "Find threshold values"
    echo "*****************"

    # Cluster results of group analysis
    # Get acf for each individual subject

    for subject in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do
        output_dir2="${input_prefix}/sub${subject}/func_rest/output.GLM_REML/acf"
        run3dFWHMx="3dFWHMx -input ${input_prefix}/sub${subject}/func_rest/output.GLM_REML/sub${subject}_${phys_type}_errts_REML.nii -acf ${output_dir2}/${subject}_${phys_type}_acf_emp.1D"
        run3dFWHMx="${run3dFWHMx} > ${output_dir2}/sub${subject}_${phys_type}_acf.1D"
        eval ${run3dFWHMx}
        #echo "eval ${run3dFWHMx}" >> ${output_dir2}/group_txt.txt
    done
fi


if [ "${DO_use_afc}" -eq 1 ]
then
    echo "*****************"
    echo "ACF values"
    echo "*****************"

    # Find average acf (4 values)
    # Get cluster information; use average acf values (first 3 numbers)

    #3dClustSim -prefix "${output_dir}/3dMEMA_${phys_type}_clust"                 \
    3dClustSim -prefix "${output_dir}/3dMEMA_${phys_type}_clust"                 \
        -acf 0.8234 3.1429 10.3091 -iter 5000 #> group_acf_txt.txt
        #-mask "${parent_dir}/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii"  \

else
    echo "*******************************"
    echo "Not doing Find threshold values"
    echo "*******************************"
fi

#echo "module load afni" > group_txt_cluster.txt
#swarm -f group_txt_cluster.txt -g 64 -t 4
#squeue -u deanjn

#https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dClusterize.html
if [ "${DO_Cluster}" -eq 1 ]
then
    echo "*****************"
    echo "Cluster results"
    echo "*****************"

    #phys: 399.7. REPLACE "num"
    #60, 18, 6.7

    3dClusterize -inset "${output_dir}/3dMEMA_${phys_type}+tlrc.BRIK"           \
        -ithr 1 -idat 0 -bisided p=0.001 -NN 1 -clust_nvox 6.7                  \
        -pref_dat "${output_dir}/3dMEMA_${phys_type}_bi_clusters_001_05.nii.gz"

        #-mask "${parent_dir}/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii"        \

else
    echo "*****************************"
    echo "Not doing Cluster results"
    echo "*****************************"
fi


if [ "${DO_mask}" -eq 1 ]
then
    echo "**********************"
    echo "Masking clustered maps"
    echo "**********************"

    3dcalc -a ${output_dir}/3dMEMA_${phys_type}_bi_clusters_001_05.nii.gz             \
          -j ${parent_dir}/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii       \
          -expr 'a * j'                                                     \
          -prefix ${output_dir}/3dMEMA_${phys_type}_bi_clusters_001_05_masked.nii.gz

          # -i ${output_dir}/3dMEMA_RMSSD_bi_clusters_001_05.nii.gz       \

else
    echo "*****************************"
    echo "Not masking"
    echo "*****************************"
fi
