#!/bin/bash
#script to run group-level analysis
#bash /mnt/d/BrainMOTOR-SCI/x.Group_SCI.sh

DO_Activation=0
DO_Threshold=0
DO_use_afc=0
DO_Cluster=1

# It's important to change these two variables!!!
group_num="group4"
regr_type="force_abs"		#pMVC, pMVCrelS1, force_abs
Grip="LGrip"				#RGrip, LGrip
scan_ses="SCAN2"			#SCAN1, SCAN2

if [ "${DO_Activation}" -eq 1 ]
then
  echo "******************"
  echo "Group activation"
  echo "******************"

  output_dir="mnt/d/BrainMOTOR-SCI/BIDS/derivatives/group3/${regr_type}/${Grip}"
  input_prefix="mnt/d/BrainMOTOR-SCI/BIDS/derivatives"
  #version="${regr_type}_${Grip}_${scan_ses}"
  version="${regr_type}_${Grip}"

  run3dMEMA="3dMEMA -prefix ${output_dir}/3dMEMA_${version}"
  run3dMEMA="${run3dMEMA} -conditions SCAN1 SCAN2"		#SCAN2 - SCAN1
  #run3dMEMA="${run3dMEMA}"
  for scan in SCAN1 SCAN2
  #for scan in ${scan_ses}
  do
	  run3dMEMA="${run3dMEMA} -set ${scan}"		#Condition of interest is whether pre- or post-hypoxia. 
	  for subject in "01" "04" "05" "06"; do

		  bcoef="${input_prefix}/I${subject}/func/${scan}/output.GLM_REML_${regr_type}/${subject}_${scan}_bcoef_${Grip}_func2stand.nii.gz"
		  tstat="${input_prefix}/I${subject}/func/${scan}/output.GLM_REML_${regr_type}/${subject}_${scan}_tstat_${Grip}_func2stand.nii.gz"
		  run3dMEMA="${run3dMEMA} ${subject} ${bcoef} ${tstat}"		#random effect is subject here too!
		  
		  echo ${subject}_${scan}_${Grip} "This dataset has made it to the important part of the loop -- YAYYYY"

	  done
  done

  run3dMEMA="${run3dMEMA} -unequal_variance"
  run3dMEMA="${run3dMEMA} -max_zeros 0.25 -model_outliers"
  #run3dMEMA="${run3dMEMA} -mask usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz"
  run3dMEMA="${run3dMEMA} -mask home/joshuadean/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz"

  eval ${run3dMEMA}

else
  echo "*****************************"
  echo "Not doing Group activation"
  echo "*****************************"
fi

# cd /mnt/j/ANVIL/Neilsen/BIDS/derivatives/group/SCAN2/LGrip/
# 3dAFNItoNIFTI 3dMEMA_v1_SCAN2_LGrip+tlrc. -prefix 3dMEMA_v1_SCAN2_LGrip.nii		#https://stackoverflow.com/questions/32728050/how-to-convert-afni-data-to-nifti-data 
# cd /mnt/j/ANVIL/Neilsen/BIDS/derivatives/group/SCAN2/RGrip/
# 3dAFNItoNIFTI 3dMEMA_v1_SCAN2_RGrip+tlrc. -prefix 3dMEMA_v1_SCAN2_RGrip.nii

#bash /mnt/d/BrainMOTOR-SCI/x.Group_SCI.sh


if [ "${DO_Threshold}" -eq 1 ]
then
  echo "*****************"
  echo "Find threshold values"
  echo "*****************"

  # Only have to run this all once for all group analyses since you are using the same subjects/models

  output_dir_2="mnt/d/BrainMOTOR-SCI/BIDS/derivatives/group/${regr_type}/${Grip}"
  input_prefix="mnt/d/BrainMOTOR-SCI/BIDS/derivatives"

  # Cluster results of group analysis
  # Get acf for each individual subject
  for subject in "01" "03" "04" "05" "06"; do
	  for scan in SCAN1 SCAN2; do
		  run3dFWHMx="3dFWHMx -input ${input_prefix}/I${subject}/func/${scan}/output.GLM_REML_${regr_type}/${subject}_${scan}_errts.nii.gz -acf ${output_dir_2}/${subject}_${scan}_acf_emp.1D"
		  run3dFWHMx="${run3dFWHMx} > ${output_dir_2}/${subject}_${scan}_acf.1D"
		  eval ${run3dFWHMx}
	  done
  done
fi

#bash /mnt/d/BrainMOTOR-SCI/x.Group_SCI.sh

if [ "${DO_use_afc}" -eq 1 ]
then
  echo "*****************"
  echo "ACF values"
  echo "*****************"

  # Find average acf (4 values)

  # Get cluster information; use average acf values (first 3 numbers)
  
  output_dir_2="mnt/d/BrainMOTOR-SCI/BIDS/derivatives/${group_num}/${regr_type}/${Grip}"
  
  3dClustSim -prefix "${output_dir_2}/3dMEMA_${regr_type}_${Grip}_${scan_ses}" \
    -mask "home/joshuadean/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz" \
    -acf 0.967514 0.894224 4.55303 -iter 5000

else
  echo "***************************"
  echo "Not doing Find threshold values"
  echo "***************************"
fi

#bash /mnt/j/ANVIL/Neilsen/x.Group.sh

if [ "${DO_Cluster}" -eq 1 ]
then
  echo "*****************"
  echo "Cluster results"
  echo "*****************"

  #https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dClusterize.html
  
  output_dir_2="mnt/d/BrainMOTOR-SCI/BIDS/derivatives/${group_num}/${regr_type}/${Grip}"
  input_prefix="mnt/d/BrainMOTOR-SCI/BIDS/derivatives"

  #previously, p=0.005 and clust_nvox 5

  3dClusterize -inset "${output_dir_2}/3dMEMA_${regr_type}_${Grip}_${scan_ses}+tlrc.BRIK" \
    -mask "home/joshuadean/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz" \
    -ithr 1 -idat 0 -bisided p=0.05 -NN 1 -clust_nvox 11 \
    -pref_dat "${output_dir_2}/${regr_type}_${Grip}_${scan_ses}_bi_clusters_05_05.nii.gz"

else
  echo "*****************************"
  echo "Not doing Cluster results"
  echo "*****************************"
fi

#"13" "14" "16" "17" "18"
# 1dplot -sepscl mnt/j/ANVIL/Neilsen/BIDS/derivatives/C01/func/SCAN2/output.GLM_REML_pMVC/01_SCAN2_matrix.1D
# 1dplot -sepscl mnt/j/ANVIL/Neilsen/BIDS/derivatives/C21/func/SCAN1/output.GLM_REML_pMVC/21_SCAN1_matrix.1D
# 1dplot -sepscl mnt/j/ANVIL/Neilsen/BIDS/derivatives/C30/func/SCAN1/output.GLM_REML_pMVC/30_SCAN1_matrix.1D

# In considering the participants: "01" "02" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"
# Task regressors seem to have properly trimmed SCAN1: C13, C14, C16, C17, C18, C19, C20, C21, C22, C23, C24, C25, C26, C27, C28, C29, C30
# Task regressors not properly trimmed SCAN1: C01, C02, C15, 





