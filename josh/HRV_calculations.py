#!/usr/bin/env python3
# python HRV_calculations.py

# RMSSD (Root Mean Square of Successive Differences): This measures the 
# square root of the mean of the squares of the differences between 
# successive NN intervals. RMSSD is commonly used as a marker of 
# parasympathetic activity (rest and digest)
# High Frequency (HF) Band: Reflects parasympathetic activity and is usually between 0.15–0.40 Hz
# Low Frequency (LF) Band: Represents both sympathetic and parasympathetic activity, typically between 0.04–0.15 Hz

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import scipy.io
import scipy.signal
from scipy.interpolate import interp1d
from scipy.signal import butter, lfilter
import statsmodels.api as sm
import json
import math

### CHANGE EVERY TIME ###
subj_id = 'sub26'
taskOI='resting'
num_MR_volumes = 1200;          #Column B: https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit#gid=591357156
MRI_scan_length = 900;          #seconds (Column F) 
freq_ds = 166.6666667           #from subXX_card_review.txt in /physio_results. Typically will be 166.666 Hz.
total_peaks = 829               #over the dataset! from subXX_card_review.txt in /physio_results
#########################

# Load the saved cardiac physiological file
datadir_results = '/data/SFIM_physio/physio_new/physio_results/' + subj_id
peak_idx = np.genfromtxt(datadir_results + '/' + subj_id + '_' + taskOI + '_card_peaks_00.1D')
peak_idx = peak_idx[0:total_peaks]    #Trim the end, such that heart rate regressor excludes the peaks post- MRI volumes stopped being collected

#########################
## Calculate HR amplitude in bpm

TR = 0.75
RR_idx_interval = []
idx_interval = []
t_peaks2 = []
t_hr = []
time_step = 1/freq_ds
for ii in range(1, len(peak_idx)):
    #calculate peak-to-peak interval distances
    idx_interval = peak_idx[ii] - peak_idx[ii-1]
    RR_idx_interval = np.append(RR_idx_interval, idx_interval)

# Note any large deviations in the RR_idx_interval --> this should not be the case and go back as necessary 
plt.plot(RR_idx_interval); plt.title('CHECK: Any crazy large deviations?\n-- RR interval'); plt.xlabel('Indices'); plt.show()

time_interval = RR_idx_interval * time_step
HR_vec = (1 / time_interval) * 60   #beats per minute
for ii in range(1, len(peak_idx)):
    ## HR timepoints
    t_peaks2 = peak_idx[ii-1] + idx_interval/2   #time in between the two peaks
    t_hr = np.append(t_hr, t_peaks2)

t_hr_vols = t_hr/freq_ds/TR       #time in volumes (TRs)

plt.plot(t_hr_vols, HR_vec); plt.title('CHECK: Heart Rate (bpm)'); plt.xlabel('Indices'); plt.show()

#########################
## Calculate heart-beat-interval (HBI) 
# average inter-heart beat intervals within a sliding window of 6 seconds (i.e., 8 TRs)
# sliding window is centered at the time of each TR

HBI_vec = []
HBI_idx = []
peak_trigger_idx = peak_idx/freq_ds/TR      #vector of times at which peaks occur (in TRs). converted from seconds to triggers
interval_dist_in_trigger = RR_idx_interval * time_step / TR
intervals_window_tmp = []
intervals_window = []
for jj in range(2, num_MR_volumes-1):       #last is not inclusive, and need 2 from end
    for kk in range(1, total_peaks-1):      #should range starting from 0 to total_peaks?
        if peak_trigger_idx[kk] > (jj-4) and peak_trigger_idx[kk] < (jj+4):     # a 6 second window is +/- 4 volumes before and after the TR in question
            # print(kk); print(peak_trigger_idx[kk]); print(interval_dist_in_trigger[kk])
            intervals_window_tmp = np.append(intervals_window_tmp, interval_dist_in_trigger[kk])    #make a temporary vector that includes all the intervals within the trigger window
            #print(jj,kk,len(intervals_window_tmp))
    #print(jj,kk,len(intervals_window))
    intervals_window = intervals_window_tmp[0:-1]           # There's systematically one too many intervals at the end (e.g., 5 peaks corresponds to 4 intervals, not 5 intervals)
    HBI_val = sum(intervals_window)/len(intervals_window)   # average interval lengths over window
    HBI_vec = np.append(HBI_vec, HBI_val)
    HBI_idx = np.append(HBI_idx, jj)
    intervals_window_tmp = []

plt.plot(HBI_idx, HBI_vec); plt.title('CHECK: HBI'); plt.xlabel('indices'); plt.ylabel('values'); plt.show()

#########################
## Calculate RMSSD
# Catie Chang, 2012 used a 45-second window, which in our case spans 60 volumes
# Also, 50% overlap. This means that the windows overlap by 30 volumes. Thus, the window moves in increments of 30 volumes
# RMSSD = √(1/(N-1) Σ 1/(RRi+1 - RRi)^2)

RMSSD_vec = []
RMSSD_idx = []
peak_trigger_idx = peak_idx/freq_ds/TR      #vector of times at which peaks occur (in TRs). converted from seconds to triggers
time_int_window = []
window_tmp =[]
window_reciprocal_sq = []
for jj in range(30, num_MR_volumes, 30):    #ends at 1470   #(30, num_MR_volumes, 30)
    for kk in range(0, total_peaks-1):
        if peak_trigger_idx[kk] > (jj-30) and peak_trigger_idx[kk] < (jj+30):
            window_tmp = np.append(window_tmp, interval_dist_in_trigger[kk])    #make a temporary vector that includes all the intervals within the window
    for ii in range(0, len(window_tmp)):        # make an array of reciprocal values of window_tmp
        window_reciprocal_sq = np.append(window_reciprocal_sq, (1/window_tmp[ii])**2)
    summed_val = sum(window_reciprocal_sq)
    RMSSD_val = np.sqrt((1/total_peaks)*summed_val)
    RMSSD_vec = np.append(RMSSD_vec, RMSSD_val)
    RMSSD_idx = np.append(RMSSD_idx, jj)
    window_tmp = []
    window_reciprocal_sq = []

plt.plot(RMSSD_idx, RMSSD_vec); plt.title('CHECK: RMSSD'); plt.xlabel('indices'); plt.ylabel('values'); plt.show()

#########################
## Demean
HR_vec_dm=HR_vec-np.mean(HR_vec)
HBI_vec_dm=HBI_vec-np.mean(HBI_vec)
RMSSD_vec_dm=RMSSD_vec-np.mean(RMSSD_vec)

## Check plots before saving files
plt.plot(t_hr_vols, HR_vec_dm); plt.title('HR_vec_dm'); plt.xlabel('Time (sec)'); plt.show()
plt.plot(HBI_vec_dm); plt.title('HBI_vec_dm'); plt.show()
plt.plot(RMSSD_vec_dm); plt.title('RMSSD_vec_dm'); plt.show()

## Save all files
np.savetxt(datadir_results + '/' + subj_id + '_HR_dm_regr' + '.tsv', np.transpose([t_hr_vols,HR_vec_dm]), '%.8f', delimiter = '\t')     #HR_vec_dm.T
np.savetxt(datadir_results + '/' + subj_id + '_HBI_dm_regr' + '.tsv', HBI_vec_dm.T, '%.8f', delimiter = '\t')
np.savetxt(datadir_results + '/' + subj_id + '_RMSSD_dm_regr' + '.tsv', RMSSD_vec_dm.T, '%.8f', delimiter = '\t')

#########################

#sinc_interp function is from: https://gist.github.com/endolith/1297227
def sinc_interp(x, s, u):
    """
    Interpolates x, sampled at "s" instants
    Output y is sampled at "u" instants ("u" for "upsampled")
    """
    
    if len(x) != len(s):
        raise Exception('x and s must be the same length')
    
    # Find the period
    T = s[1] - s[0]
    
    sincM = np.tile(u, (len(s), 1)) - np.tile(s[:, np.newaxis], (1, len(u)))
    y = np.dot(x, np.sinc(sincM/T))
    return y

t_ups_RMSSD = np.arange(start=RMSSD_idx[0], stop=RMSSD_idx[-1], step=1)     #in MR volumes, so step 1 is same as step = TR in seconds
RMSSD_vec_dm_interp = sinc_interp(RMSSD_vec_dm, RMSSD_idx, t_ups_RMSSD)
plt.plot(t_ups_RMSSD, RMSSD_vec_dm_interp); plt.title('RMSSD_vec_dm sinc_interp'); plt.show()
np.savetxt(datadir_results + '/' + subj_id + '_RMSSD_dm_interp_regr' + '.tsv', RMSSD_vec_dm_interp.T, '%.8f', delimiter = '\t')

t_ups_HR = np.arange(start=0, stop=num_MR_volumes, step=1)
HR_vec_dm_interp = sinc_interp(HR_vec_dm, t_hr_vols, t_ups_HR)
plt.plot(HR_vec_dm_interp); plt.title('HR interpolated'); plt.show()
np.savetxt(datadir_results + '/' + subj_id + '_HR_dm_interp_regr' + '.tsv', HR_vec_dm_interp.T, '%.8f', delimiter = '\t')
