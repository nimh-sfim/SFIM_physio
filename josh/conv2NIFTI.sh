#!/bin/bash
# bash conv2NIFTI.sh
# bash /data/SFIM_physio/scripts/conv2NIFTI.sh
# This script converts AFNI's data format to NIFTI

parent_dir="/data/SFIM_physio/data/"
taskOI="outhold"						#resting, inhold, outhold
task4letters="bouh"						#rest, binh, bouh
#delay_range="-9sto18s" 					#"0sto21s", "-9sto18s", "0sto21s_sinwaves", "-9sto18s_sinwaves" <-- will need to re-do -9sto18s
#file_type="stats" 						#"stats", "RespFunc" <-- RespFunc is already done
afni2nii=1

for subject in "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34"; do 
#for subject in "14"; do 

    echo ${subject} "is processing"

	if [ "${afni2nii}" -eq 1 ]
	then
		convert_dir="/data/SFIM_physio/data/derivatives/sub${subject}/func_${task4letters}_MAPRF_out/"
		cd ${convert_dir}
        #"/Volumes/SFIM_physio/data/bp20/func_binh/pb04.bp20.r01.scale.nii"
		#3dAFNItoNIFTI ${subject}_${taskOI}_MAP_lagged_${delay_range}_${file_type}_AA1+tlrc -prefix ${subject}_${taskOI}_MAP_lagged_${delay_range}_${file_type}_AA1.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set1_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set1_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set2_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set2_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set3_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set3_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set4_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set4_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set5_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set5_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set6_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set6_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set7_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set7_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set8_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set8_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set9_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set9_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set10_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set10_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set11_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set11_stats.nii
		# 3dAFNItoNIFTI ${subject}_${taskOI}_MAP_set12_stats+tlrc -prefix ${subject}_${taskOI}_MAP_set12_stats.nii
		#3dAFNItoNIFTI ${subject}_${taskOI}_MAP_lagged_-9sto18s_dl4TR_stats+tlrc -prefix ${subject}_${taskOI}_MAP_lagged_-9sto18s_dl4TR_stats.nii

		3dAFNItoNIFTI sub${subject}_Tcorr_ycoef+tlrc -prefix sub${subject}_Tcorr_ycoef.nii

		3dAFNItoNIFTI sub${subject}_${taskOI}_MAP1D_coeff+tlrc -prefix sub${subject}_${taskOI}_MAP1D_coeff.nii

		# sub${sbjid}_Tcorr1D_pearson
		# sub${sbjid}_Tcorr1D_fisher
		# sub${sbjid}_Tcorr_ycoef

	fi

done

# 3dAFNItoNIFTI 18_inhold_MAP_set1_stats+tlrc -prefix 18_inhold_MAP_set1_stats.nii

