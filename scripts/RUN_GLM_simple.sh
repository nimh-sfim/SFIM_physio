#!/bin/bash
# bash /Volumes/SFIM_physio/scripts/RUN_GLM_simple.sh

input_file="${1}"
ratio_file="${2}"
sub_ID="${3}"
output_dir=${4}

parent_dir="/Volumes/SFIM_physio/data"
regr_type="force_abs"
S_num="S2"			#Change

for subject in "01" "03" "04" "05" "06"; do 
	for scan in SCAN2; do

		input_file=${parent_dir}/derivatives/I${subject}/func/${scan}/output.SPC/${subject}_${scan}_SPC.nii.gz

		LGrip=mnt/d/BrainMOTOR-SCI/phys/I${subject}/${scan}/I${subject}_${S_num}_BrainHG_LGrip_HRFconv_${regr_type}_rm18_trimmed.txt
		RGrip=mnt/d/BrainMOTOR-SCI/phys/I${subject}/${scan}/I${subject}_${S_num}_BrainHG_RGrip_HRFconv_${regr_type}_rm18_trimmed.txt
		CO2_file=mnt/d/BrainMOTOR-SCI/phys/I${subject}/${scan}/I${subject}_task-motor_CO2_HRFconv_rm18.txt

		sub_ID=${subject}_${scan}
		output_dir=${parent_dir}/derivatives/I${subject}/func/${scan}/output.GLM_REML_${regr_type}

		mnt/d/BrainMOTOR-SCI/x.GLM_REML_SCI.sh ${input_file} ${motion_file} ${LGrip} ${RGrip} ${CO2_file} ${sub_ID} ${output_dir}

    done
done


