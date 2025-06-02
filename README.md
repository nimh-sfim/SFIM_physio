# Physiological Networks Project
Burak Akin and Josh Dean are working to understand what additional information blood pressure can contribute in modeling BOLD fMRI data. In this project, we process physio data (including mean arterial pressure, low frequency oscillations -- of PPG -- and respiration), fMRI data, and analyze the data. Note that preprocessed fMRI data was completed outside the scope of this project and done by Burak & Javier before I (Josh) started on the project. 

The scripts that this README covers is found in Biowulf here: /data/SFIM_physio/scripts/josh/

Scripts that we aren't using but had previously used may be found here: /data/SFIM_physio/scripts/scripts_no_longer_use_josh/. These scripts cover earlier iterations of the project, like when we were interested in heart rate variability (HRV) or heart rate (HR). Analysis approaches that we didn't pursue further are also covered in this folder. 

## Description of the breathing tasks (inhold and outhold) after checking PsychoPy (in which I ran the script and checked the logs)
1. Inhold cycle (55s long):
- 2 seconds to start the cycle; Participant can do whatever they want
- 5 second inhale
- 15 second breath hold
- 3 second exhale
- 30 second free breathing
2. Outhold cycle (55s long):
- 2 seconds to start the cycle; Participant can do whatever they want
- 5 second inhale
- 3 second exhale
- 15 second breath hold
- 30 second free breathing

# How to process the phys data:
## MAP
1. extMAP1_save_as_txt_resamp.m -- saves the CareTaker excel data from an uneven sampling grid to an even sampling grid and exports this data as a .tsv file.
1. extMAP2_xcorr_starttime.m -- synchronizes the CareTaker resampled data to the BIOPAC's PPG data to demarcate which of the CareTaker data corresponds to which task. This loops across all subjects. Once synchronized, we extract the CareTaker's calculated blood pressure data. 
1. extMAP3_xcorr_starttime_manual.m -- For instances where cross correlation was less than 0.5, I manually checked to see which indices would provide for more optimal fits. For information about the cross correlation values, automated indices, and whether I was able to synchronize or changed the automated indices, across subject-task pairings, please see /data/SFIM_physio/scripts/Pulse_Caretaker_xcorr_to_PPG_for_MAP_synchronization.xlsx. For detailed information about what each of these processes looked like, please see /data/SFIM_physio/scripts/Manual_Checks_for_Synchronization_ACQ_CareTaker.pptx
1. resample2TR_phys_ts.m -- resamples the MAP timeseries (or LFO) to TR space. 
1. savetsvastable.m -- saves the MAP (or LFO) timeseries with a header. This is useful for AFNI or Rapidtide because these programs assume the first row is a header, so if there isn't a header present, the first row of data will be lost (and for the case of Rapidtide, the resulting delay maps would be 1 TR off)
## LFO
1. convert_ppg2txt.m -- To run AFNI's 3dToutcount, it's necessary to downsample the data (because ~450,000 datapoints is crazy long). AFNI would also like to read in a file that's not ACQ format. 
1. RUN_censor.sh -- uses 3dToutcount to create a first-pass approximation where I may or may not need to censor the PPG traces. Also does a few things like converting the PPG from .txt to .1D and whatnot. 
1. gen_LFO_final.m -- calculates the low-frequency component of the PPG trace so as to generate the low-frequency oscillation (LFO) regressor. This script also performs censoring of the noisy PPG trace segments (where we make the length of the segment equal to zero). This requires manual corrections of the PPG trace before LPF'ing, and as a starting off point, I use the results from 3dToutcount to start off the process of determining where to censor. Note that this may be an iterative process and can be time consuming (as I check each boxcar and if it sufficiently encapsulates what should be censored). 3dToutcount also marks peaks that I wouldn't otherwise censor in some instances, so I also manually correct these regions as well as I make the LFO regressors (i.e., I won't just increase the width of boxcar segments, but I may also remove them). I also update the censored locations and save this as a text file for future reference. 
1. resample2TR_phys_ts.m -- resamples the LFO timeseries (or MAP) to TR space. 
1. savetsvastable.m -- saves the LFO (or MAP) timeseries with a header. This is useful for AFNI or Rapidtide because these programs assume the first row is a header, so if there isn't a header present, the first row of data will be lost (and for the case of Rapidtide, the resulting delay maps would be 1 TR off)
## RVT
1. generate_bids_format_from_acq.sh -- an .acq file can be difficult to work with, so we convert the file into the BIDS format (output is a .tsv.gz and .json file)
1. change_column_names_json.py -- our .json file does not have standard BIDS names for respiration, cardiac, and trigger. We need to change these names to be in a standard format when using physio_calc.py, so that AFNI can tell which column of the text file corresponds to what kind of data.
1. change_trigger_values2bids.py -- when converting to BIDS format, there are a few things that the bidsphysio module (used in first step) does not do well. When the trigger is on, it should have a value of 5.0, and when off, it should have a value of 0.0. However, this is not the case for our new text file. This script corrects these trigger values.
1. normalize_acq_card.py -- when converting to BIDS format, the bidsphysio module rounds every number to the fourth decimal place. The cardiac data is often less than 1, so that means specificity is lost upon converting to BIDS format. Thus, now that we have the text file, we extract the cardiac information from the .acq file that has not been rounded, normalize it, and insert it into the cardiac column of the text file. 
1. RUN_physiocalc.sh -- generate cardiac and respiratory regressors using AFNI. 
1. HRV_calculations.py -- no longer in use, as unnecessary given a re-focus on LFO instead of the higher frequency components of the PPG trace... But to note, this script loads in the cardiac peak indices generated from physio_calc.py to generate (a) HR timeseries, (b) HBI timeseries, (c) RMSSD timeseries for each subject, then rescales, demeans, downsamples, trims, and saves these three timeseries (this is true as of Sept. 28, 2024, but may change)

# Other phys stuff
## Plots of phys data
1. plot_regr_group.m -- plots the LFO and MAP timeseries at a subject- and group-level. Additionally plots the trial average for the breathing tasks as well as places background boxes within the plot to designate what part of the plot corresponds to what element of the task. This is tentatively planned to be used to generate Figure 1 for the paper. 
1. xcorr_phys.m -- calculates and saves the lagged cross correlations across the phys datas. Burak may have generated his own similar script though. 
1. plot_xcorr_phys.m -- plots the lagged cross correlations of MAP, LFO, and the subject average GM timeseries. Also plots the group-level lagged cross correlation. This might be used to generate Figure 2 for the paper, but Burak may have generated his own similar script. 
## Miscellanous for the phys
1. CT_BP_lowxcorr_check.m -- loops across all subjects to determine which subjects had low cross correlations between the Caretaker pulse recording and the ACQ data. This is useful not only for a sanity check but also beneficial to see which subjects had ~relatively poor quality phys data. 
## Notes about physio data:
1. I believe that outhold.acq is a duplicate of resting.acq for sub11. outhold2.acq appears to be unique from the other ACQ files, and thus, I am using outhold2.acq moving forward. 
1. sub12's respiration trace is digitized and not recoverable (or at least I don't know how you'd go about fixing it). Should confirm with Burak. 
1. Earlier subjects' cardiac data is noisier. I think Dan had mentioned that the pulse oximeter was faulty around the time he was collecting his early subjects as well. Not sure if that's the reason.

# Response Functions
1. lagged_map_design_mat.m -- Generates the design matrix of lagged MAP timeseries, one lagged timeseries per column. 
1. RUN_3dDeconvolve_RespFunc_dl{1..6}TR.sh -- uses 3dDeconvolve to generate voxel-specific response functions, with each beta corresponding to the fit coefficient at a lagged time. We tried six different variations of how far apart these lagged times would be, as a 1TR difference was far too spiky and noisy of a result (colinearity?). Currently using *_dl4TR.sh because the response functions at the voxel-level within a few subjects had fairly consistent shapes, and this was still a conservative approach relative to *_dl3TR, which Dan (Handwerker) had suggested was good enough too. RUN_3dDeconvolve_RespFunc_sine.sh is no longer being used, but this was another approach that Dan had suggested to use to generate voxel-specific response functions. 
1. interp_voxel_respfunc.m -- interpolates the voxel-specific response functions. Currently using response functions that were generated using 4TR shifts, so we re-interpolate the response functions such that there's one datapoint per TR. 
1. conv_voxel_MAPRF.m -- convolves the voxelwise response functions with the subject's MAP timeseries and saves these convolved timeseries for each voxel in a NIFTI format. 
1. gen_ResponseFunction_interp_thr.m -- now that I have voxelwise response functions, this script determines what these subjects' response functions look like across thresholded and/or masked voxels and what the group-level response function looks like. The group-level response function isn't particularly meaningful however. 
1. create_NIFTI_of_1DMAP_not_convolved.m -- double check if this is still necessary later??? Not sure... If not, delete the file. 

# Functional connectivity stuff: 
## Overall, I wanted to see if connectivity changed if we were to consider three different regression conditions, either regressing out the voxelwise MAP response function convolved with the MAP timeseries (MAPxRF), regressing out the non-convolved MAP timeseries (MAP1D), or not regressing any physiological signal (NAH). Below are the functions I used to investigate this. 
1. RUN_3dDetrend.sh -- detrended (and demeaned) the original fMRI pb04 data. Burak mentioned that the brain data should have been detrended already with afni_proc.py, but when looking at the voxel timeseries, it seemed like the pb04 brain data could still benefit from detrending, so I did it anyways. May not be necessary though. 
1. create_NIFTI_of_1DMAP_not_convolved.m -- generates a 4D NIFTI file that solely contain the same subject-specific MAP timeseries. Will be used as one of the inputs when running 3dcalc in one of the next steps. 
1. RUN_3dTcorrelate.sh -- using 3dTcorrelate to generate the fit coefficients wrt the voxelwise response function convolved with the MAP regressor
1. RUN_3dDeconvolve_MAP1D.sh -- uses 3dDeconvolve to generate the fit coefficients wrt the 1D MAP regressor. I previously used RUN_3dTcorr.1D.sh for something like this, but that script is no longer used because I'm now using 3dDeconvolve to do this.
1. conv2NIFTI.sh -- converts brain data from AFNI .tlrc format to NIFTI format
1. RUN_3dcalc_regress_fitted_mapts.sh -- using 3dcalc to regress out the MAP signal, in which I subtracted the product of the fit coefficients and the MAP regressors from the detrended fMRI pb04 data
1. seedbased_funcconn.m -- performs a seed based functional connectivity analysis from within MATLAB, in which all voxels were correlated to one of the three seeds
1. group_average_niftis_funccorr.m -- group averaged the functional connectivity maps across subjects, given the task and seed
1. parcel_corr_avgs_funccorr.m -- look at how the average correlation values within defined parcels, as defined by the Yeo 100 parcel atlas, compared across these group-averaged maps. As of the end of May 2025, we optimistically found that when we regress out MAP from the detrended brain data that functional connectivity increased and even more so when we convolved the MAP timeseries to voxel-specific response functions. However, these results, while fairly consistent, were subtle and modest. 
1. spatial_differences_regression_corr.m -- subtracts two sets of brain maps from one another and saves as NIFTI. This was used to determine the voxelwise spatial differences between the different regression approaches taken. Not very exciting results though. We found that the differences were proportional with the magnitude of the fit within a voxel.

# How to process the fMRI data:
## RapidTide
1. conv2NIFTI.sh -- if necessary, convert the fMRI preprocessed data from AFNI to NIFTI format
1. RUN_rapidtide_card_lfo_rest_singularity.sh -- generates Rapidtide outputs using the LFO regressor for resting-state fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. RUN_rapidtide_card_lfo_binh_singularity.sh -- generates Rapidtide outputs using the LFO regressor for inhold fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. RUN_rapidtide_card_lfo_bouh_singularity.sh -- generates Rapidtide outputs using the LFO regressor for outhold fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. RUN_rapidtide_bp_rest_singularity.sh -- generates Rapidtide outputs using the MAP regressor for resting-state fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. RUN_rapidtide_bp_binh_singularity.sh -- generates Rapidtide outputs using the MAP regressor for inhold fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. RUN_rapidtide_bp_bouh_singularity.sh -- generates Rapidtide outputs using the MAP regressor for outhold fMRI data. For the bash script that doesn't include "_singularity" at the end, the singularity image provided by Blaise Frederick was not used. 
1. group_average_niftis_rapidtide.m -- generate group-level maxtime_map.nii.gz and maxcorr_map.nii.gz from subject-level Rapidtide results
1. parcel_corr_avgs_rapidtide.m -- across the 100 parcels, as defined by Yeo, this script determines if LFO or MAP provide higher correlations to the detrended brain data. Optimistically, we found that MAP had higher correlations in the GM. 
1. plot_histograms_rapidtide.m -- plots the voxel maxtime and maxcorr distributions in histograms across subjects to examine the subject variability. Also plots the group distributions. 
1. norm2GM_median_group.m -- Normalize the maxtime group Rapidtide results to the grey matter median. This may not actually be very helpful, but I was interested in doing this to see how LFO and MAP propagate different across the brain *once it's already arrived in the brain*. I did this also in part because then I wouldn't have to customize the color bars when visualizing the brain data. I intended this solely for visualization purposes.
1. file_exist_check.sh -- unfortunately, across the different iterations of the Rapidtide command we've tried, it's commonplace for some (or many) subject-task pairings to not output any meaningful results (i.e., brain data). Here, I simply loop across all subjects to see which files *do not* exist for the expected Rapidtide outputs. 

# Other scripts
1. RUN_3dresample.sh -- resamples one set of brain data to be in the same space as another set of brain data using AFNI's 3dresample function. Mostly used this to bring other atlases into MNI space (and thus same space as pb04 subject brain data). 
1. Group_3dttest_testing.sh -- potentially for group-level analyses using AFNI's 3dttest++
1. As a group, spatialcorr_function.m, spatialcorr_vals.m, and spatialcorr_plot.m can be used to find the spatial correlation between two different brain maps. 
1. violin_delay_dists.m -- Plot violin distributions for Rapidtide delay maps to compare across phys conditions. Was created to be potentially included in the BSC report.
1. network_conn.m -- plots network connectivity matrix
1. vis_rapidtide_subject.m and vis_rapidtide_group.m saves plots of the Rapidtide results to a specified folder. 

**Link to GitHub repo:** https://github.com/nimh-sfim/SFIM_physio
