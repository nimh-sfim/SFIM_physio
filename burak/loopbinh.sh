#!/bin/bash
set -e
module load afni

# Loop through subjects from bp26 to bp34 and run afni_binh_function
for i in 27 28 29; do
    afni_proc.py -subj_id "bp${i}" \
        -blocks tcat despike tshift align tlrc volreg mask scale regress \
        -radial_correlate_blocks tcat volreg \
        -copy_anat "/data/akinb2/allbp/bp${i}/anat/anatSS.bp${i}.nii" \
        -anat_has_skull no \
        -anat_follower_ROI aaseg  anat "/data/akinb2/allbp/fsurfs/bp${i}/SUMA/aparc.a2009s+aseg.nii" \
        -anat_follower_ROI aeseg  epi  "/data/akinb2/allbp/fsurfs/bp${i}/SUMA/aparc.a2009s+aseg.nii" \
        -tcat_remove_first_trs 0 \
        -dsets "/data/akinb2/allbp/bp${i}/binh.nii" \
        -align_opts_aea -cost lpc+ZZ -giant_move -check_flip \
        -tlrc_base MNI152_2009_template_SSW.nii.gz \
        -tlrc_NL_warp \
        -tlrc_NL_warped_dsets "/data/akinb2/allbp/bp${i}/anat/anatQQ.bp${i}.nii" \
              "/data/akinb2/allbp/bp${i}/anat/anatQQ.bp${i}.aff12.1D" \
              "/data/akinb2/allbp/bp${i}/anat/anatQQ.bp${i}_WARP.nii" \
        -volreg_align_to first \
        -volreg_align_e2a \
        -volreg_tlrc_warp \
        -volreg_warp_dxyz 2 \
        -mask_epi_anat yes \
        -regress_opts_3dD -jobs 32 \
        -regress_motion_per_run \
        -regress_censor_motion 0.25 \
        -regress_censor_outliers 0.05 \
        -regress_apply_mot_types demean \
        -regress_bandpass 0.01 0.1 \
        -regress_polort 4 \
        -regress_run_clustsim no \
        -html_review_style pythonic \
        -out_dir "/data/akinb2/allbp/bp${i}/func_binh" \
        -script  "preproc_binhbp${i}.sh" \
        -volreg_compute_tsnr yes \
        -regress_compute_tsnr yes \
        -regress_make_cbucket yes \
        -scr_overwrite
done
fi
