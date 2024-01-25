#!/usr/bin/env python3
# python map_hr_analysis.py 

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os
import scipy.io
import scipy.signal
from scipy.interpolate import interp1d
from scipy.signal import butter, lfilter
import statsmodels.api as sm

# Change every time
subj_id = 'sub20'       #sub13, sub15, sub16, sub17, sub18, sub20
MRI_scan_length = 900   #seconds

# Load in MAP .mat file (blood pressure) and heart rate .tsv file
datadir_map = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/' + subj_id + '/'
datadir_hr = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_results/' + subj_id + '/'
map_filename = subj_id + "ct.mat"
hr_filename = subj_id + "_heart-rate.tsv"
map = scipy.io.loadmat(os.path.join(datadir_map, map_filename))
hr = pd.read_csv(os.path.join(datadir_hr, hr_filename),sep='\t')
hr_time = hr.iloc[:,0]
hr_data = hr.iloc[:,1]

# Get dictionary keys as a list ( alternative: data.keys() )
keysList = list(map.keys())
for ii in range(0, len(keysList)):  
    print(keysList[ii], np.shape(map[keysList[ii]]))
# Define map data arrays
map_data = map['maprest_fmri']    # map['bp']
map_data = map_data[0]

# Plot
fig, ax = plt.subplots(2,1)
ax[0].plot(hr_time, hr_data); ax[0].set_ylabel('HR (bpm)'); ax[0].set_xlabel('Time (sec)')
ax[1].plot(map_data); ax[1].set_ylabel('MAP'); ax[1].set_xlabel('TR Volumes')
fig.subplots_adjust(hspace=0.3)
plt.show()

############ MAP INTERPOLATION ############
# solution from: https://dsp.stackexchange.com/questions/83696/downsample-a-signal-by-a-non-integer-factor

map_data_mean = np.mean(map_data)
map_data = map_data - map_data_mean

T = len(map_data)                                           #number of samples in original data to be downsampled
t = np.linspace(0, MRI_scan_length, T, endpoint=True)       #array of indices in original data to be downsampled
x = map_data                                                #original data to be downsampled

t2 = hr_time                                                #indices for the soon-to-be downsampled data; int(T/ratio) should equal len_map_after_interp = len_hr + 1
freq_crit = 1/(2*0.2)                                       #Has to be 0 to 1, exclusive
b, a = butter(4, freq_crit, btype='lowpass', analog=False, fs=50)      
x_lpf = lfilter(b, a, x)

interpolated = interp1d(t, x_lpf, kind='linear')            #linear, quadratic, cubic

plt.plot(t,x)
plt.plot(t2,interpolated(t2),'.'); plt.title('downsampled map (orange dots) on top of original map (blue line)')
plt.show()

map_data_ds = interpolated(t2) + map_data_mean
plt.plot(map_data_ds); plt.show()

############ HEART RATE FILTERING ############

hr_data_mean = np.mean(hr_data)
hr_data = hr_data - hr_data_mean

T = len(hr_data)                                            #number of samples in original data to be downsampled
t = hr_time                                                 #array of indices in original data to be downsampled
x = hr_data                                                 #original data to be downsampled

t2 = hr_time                                                #indices for the soon-to-be downsampled data; int(T/ratio) should equal len_map_after_interp = len_hr + 1
cut_off=0.5
freq_crit = 1/(2*cut_off)                                   #Has to be 0 to 1, exclusive
b, a = butter(2, freq_crit, btype='lowpass', analog=False, fs=50)      
x_lpf = lfilter(b, a, x)

interpolated = interp1d(t, x_lpf, kind='linear')            #linear, quadratic, cubic

plt.plot(t,x)
plt.plot(t2,interpolated(t2),'.'); plt.title('downsampled HR (orange dots) on top of original HR (blue line)')
plt.show()

hr_data_ds = interpolated(t2) + hr_data_mean
plt.plot(hr_data_ds); plt.show()

############# Plotting Relationships ########################

fig, ax = plt.subplots(2,1)
ax[0].plot(hr_time, hr_data_ds); ax[0].set_ylabel('HR (bpm)'); ax[0].set_xlabel('Time(sec)')
ax[1].plot(hr_time, map_data_ds); ax[1].set_ylabel('MAP'); ax[1].set_xlabel('Time(sec)')
fig.subplots_adjust(hspace=0.3)
plt.show()

# Scatterplot
plt.scatter(map_data_ds, hr_data_ds)
plt.xlabel('map'); plt.ylabel('HR')
plt.show()

# Histogram of ratio
hr_map_ratio = hr_data_ds / map_data_ds
n_bins = 20
plt.hist(hr_map_ratio, bins=n_bins)
plt.ylabel('count'); plt.xlabel('ratio'); plt.title('ratio defined as hr_data_ds / map_data_ds')
plt.show()

# Bland-Altman plot -- measures agreement between two signals 
# https://stackoverflow.com/questions/16399279/bland-altman-plot-in-python --> maybe plot after normalization because are on different scales
map_data_ds_norm = map_data_ds / np.max(map_data_ds)
hr_data_ds_norm = hr_data_ds / np.max(hr_data_ds) 
f, ax = plt.subplots(1, figsize = (8,5))
sm.graphics.mean_diff_plot(hr_data_ds_norm, map_data_ds_norm, ax = ax)
plt.show()

############# Make the task regressor ############# 

z_hr_map_ratio = scipy.stats.zscore(hr_map_ratio)

ratio_std = np.std(z_hr_map_ratio)
ratio_avg = np.mean(z_hr_map_ratio)
upper_thres_scalar = 1.1
lower_thres_scalar = 1.3
upper_thres = ratio_avg + upper_thres_scalar*ratio_std
lower_thres = ratio_avg - lower_thres_scalar*ratio_std

binarized_regr = np.zeros(len(z_hr_map_ratio))
for ii in range(0,len(binarized_regr)):
    if z_hr_map_ratio[ii] > upper_thres:
        binarized_regr[ii] = 1
    if z_hr_map_ratio[ii] < lower_thres:
        binarized_regr[ii] = -1

# QC'ing the binary regressor, and change scalar values accordingly
plt.subplot(5, 1, 1); plt.plot(hr_time, hr_data_ds); plt.ylabel('HR');plt.title(str(subj_id))
plt.subplot(5, 1, 2); plt.plot(hr_time, map_data_ds); plt.ylabel('MAP')
plt.subplot(5, 1, 3); plt.plot(hr_time, hr_map_ratio); plt.ylabel('HR/MAP Ratio')
plt.subplot(5, 1, 4); plt.plot(hr_time, z_hr_map_ratio); plt.ylabel('Norm HR/MAP Ratio')
plt.axhline(y=upper_thres, color = 'r', linestyle = '--', label=str(upper_thres_scalar) + ' stds')
plt.axhline(y=lower_thres, color = 'g', linestyle = '--', label=str(lower_thres_scalar) + ' stds')
plt.legend() 
plt.subplot(5, 1, 5); plt.plot(hr_time, binarized_regr); plt.ylabel('Task Regressor')
plt.xlabel('Time (seconds)')   #indices are defined by position in between peaks
plt.show()


