# Physiological Networks Project
Burak Akin and Josh Dean are working to understand what additional information blood pressure can contribute regarding physiological networks. In this project, we process physio data (including heart rate, mean arterial pressure, and respiration), fMRI data, and analyze the data.

## How to process the phys data:

I'm going to try to debug why the RR intervals look so digitized. As an example, I'll run through sub13. I'll try these options:
a. cardiac data from .acq file, *Channel C9 - PPGfiltered* --> what I'm currently using
b. cardiac data from .acq file, *Channel PPG100C* (which I presume to be unfiltered)
c. cardiac data from subXX_map.mat, *Pulse* (found on OneDrive); not normalized (i.e., skipping step 4)
d. process all three using different downsampling frequencies using physio_calc.py
This means that I will be making 9 regressors, if I use 3 different sets of frequencies
After completing the analysis, Option A looks to be the most appropriate. See slideshow here for details: https://docs.google.com/presentation/d/12UxoRHP_MhSuZqVeulOSqemu1CAMvHUK186rhxM1txM/edit?usp=sharing

1. generate_bids_format_from_acq.sh -- an .acq file can be difficult to work with, so we convert the file into the BIDS format (output is a .tsv.gz and .json file)
2. change_column_names_json.py -- our .json file does not have standard BIDS names for respiration, cardiac, and trigger. We need to change these names to be in a standard format when using physio_calc.py, so that AFNI can tell which column of the text file corresponds to what kind of data.
3. change_trigger_values2bids.py -- when converting to BIDS format, there are a few things that the bidsphysio module (used in first step) does not do well. When the trigger is on, it should have a value of 5.0, and when off, it should have a value of 0.0. However, this is not the case for our new text file. This script corrects these trigger values.
4. normalize_acq_card.py -- when converting to BIDS format, the bidsphysio module rounds every number to the fourth decimal place. The cardiac data is often less than 1, so that means specificity is lost upon converting to BIDS format. Thus, now that we have the text file, we extract the cardiac information from the .acq file that has not been rounded, normalize it, and insert it into the cardiac column of the text file. 
5. RUN_physiocalc.sh -- generate cardiac and respiratory regressors using AFNI. 
6. HRV_calculations.py -- loads in the cardiac peak indices generated from physio_calc.py to generate (a) HR timeseries, (b) HBI timeseries, (c) RMSSD timeseries for each subject, then rescales, demeans, downsamples, trims, and saves these three timeseries (this is true as of Sept. 28, 2024, but may change)
7. WHAT ABOUT MAP?????!!!! COME BACK TO THIS


## Notes about physio data:
1. sub12's respiration trace is digitized and not recoverable (or at least I don't know how you'd go about fixing it). Should confirm with Burak. 
2. sub11's physio data is too short, so not calling EPI when running RUN_physiocalc.sh
3. Earlier subjects' cardiac data is noisier. I think Dan had mentioned that the pulse oximeter was faulty around the time he was collecting his early subjects as well. Not sure if that's the reason.
4. AS OF SEPT 27, I NEED TO GO BACK TO CENSOR CARDIAC!!!****
5. Notes regarding HRV_calculations per subject of note:
--> in general, even though I set freq to be 200 Hz for physio_calc.py, the freq was actually 166.66 Hz. 
--> sub12 - erroneous peak was kept... manually corrected the *_card_peaks_00.1D file, which also means that the cardiac RETROICOR regressors can't be used. I'll have to generate them myself later. I deleted index 44202 and also updated the number of peaks in the *_card_review.txt file (for each to be one less than originally listed). was okay after that!
--> sub14 - somehow ig I missed times (s) roughly at: 118, 185, 416, so I manually corrected the *_card_peaks_00.1D file again, corresponding to deleting index 19448, and adding indices 30882 (in between 30729 and 31034) and 69585 (in between 69438 and 69732). Thus, I added net 1 peak in total, and I reflected this change in the *_card_review.txt file. 


## How to process the fMRI data:
1. Preprocessed fMRI data was completed outside the scope of this project
2. For subject-level GLM with cardiac regressor, use x.GLM_REML_card.sh and RUN_GLM_card.sh 
3. For subject-level GLM with MAP regressor, use x.GLM_REML_MAP.sh and RUN_GLM_MAP.sh.
4. conv2NIFTI_3dbucket_norm2MNI.sh -- does three tasks: (1) converts .tlrc to NIFTI, (2) extracts beta and tstat sub-bucket from bucket file via AFNI's 3dbucket, and (3) can also normalize to MNI space using AFNI's autowarp.
5. For group-level analysis, use x.Group.sh


**Link to GitHub repo:** https://github.com/nimh-sfim/SFIM_physio

