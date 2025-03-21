#!/bin/bash
# bash conv2NIFTI.sh
# bash /data/SFIM_physio/scripts/conv2NIFTI.sh
# This script converts AFNI's data format to NIFTI

parent_dir="/data/SFIM_physio/data/"
afni2nii=1

#"10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25"
for subject in "26" "27" "28" "29" "30" "31" "32" "33" "34"; do 

    echo ${subject} "is processing"

	if [ "${afni2nii}" -eq 1 ]
	then
		convert_dir="${parent_dir}/bp${subject}/func_binh/"     #func_rest, func_binh, func_bouh
		cd ${convert_dir}
        #"/Volumes/SFIM_physio/data/bp20/func_binh/pb04.bp20.r01.scale.nii"
		3dAFNItoNIFTI pb04.bp${subject}.r01.scale+tlrc -prefix pb04.bp${subject}.r01.scale.nii
	fi

done

