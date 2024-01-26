#!/usr/bin/env python3
# python RRcalc.py

import numpy as np
import matplotlib.pyplot as plt
import os
import scipy.io
import scipy.signal
from scipy.interpolate import interp1d
from scipy.signal import butter, lfilter
import json

### CHANGE EVERY TIME ###
freq_ds = 50            #from subXX_card_review.txt
peak_num_dset = 943     #from subXX_card_review.txt
subj_id = 'sub20'
#########################

# Load the saved cardiac physiological file
datadir_results = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_results/' + subj_id + '/'
peak_idx = np.genfromtxt(datadir_results + '/' + subj_id + "_card_peaks_00.1D")
peak_idx = peak_idx[0:peak_num_dset]    #Trim the end, such that heart rate regressor excludes the peaks post- MRI volumes stopped being collected

# Calculate the heart rate
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
plt.plot(RR_idx_interval); plt.title('RR interval'); plt.xlabel('Indices'); plt.show()

# Calculate HR amplitude
for ii in range(1, len(peak_idx)):
    time_interval = RR_idx_interval * time_step
    heart_rate = (1 / time_interval) * 60   #beats per minute
    #calculate timepoint for corresponding HR
    t_peaks2 = peak_idx[ii-1] + idx_interval/2   #time in between the two peaks
    t_hr = np.append(t_hr, t_peaks2)

time_hr = t_hr * time_step
plt.plot(heart_rate); plt.title('Heart Rate'); plt.xlabel('Indices'); plt.show()
plt.plot(time_hr, heart_rate); plt.title('Heart Rate'); plt.xlabel('Time'); plt.show()

np.set_printoptions(suppress=True)
hr_data = np.array([time_hr, heart_rate])
hr_data = hr_data.T         #transform to column vectors
np.savetxt(datadir_results + subj_id + '_heart-rate.tsv', hr_data, '%.4f', delimiter = '\t') #fmt='%i,%i')

# Now that I have generated the heart rate regressor, analyze how blood pressure relates to heart rate in map_hr_analysis.py
# end



# Stay in the downsampled freq space of freq_ds (I was going up to the 1000 Hz earlier, which was wrong and have since edited this)
# Another change I've made since talking with Burak: since I interpolated while making the regressors, there is no need to do so here. 
## Sections of code I'm not using anymore... 
# datadir_files = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/' + subj_id + '/'
# Determine which column the filtered cardiac data is in (should end up being index 3 though)
# filepath = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/' + subj_id + '/'
# filename_json = subj_id + '_resting_physio.json'
# file = os.path.join(filepath,filename_json)
# with open(file, 'r+') as f:
#     data = json.load(f)
#     cardiac_filt_idx_counter = 0
#     freq_orig = data['SamplingFrequency']
#     for ll in data['Columns']:
#         if ll == 'cardiac':
#             cardiac_filt_idx = cardiac_filt_idx_counter
#         cardiac_filt_idx_counter += 1    #this is the variable that marks the index for which column *FILTERED* cardiac belongs (do use this column over unfiltered cardiac)
# card_input_data = np.genfromtxt(datadir_files + '/' + subj_id + '_resting_physio.tsv')[:,cardiac_filt_idx]
# plt.plot(card_input_data); plt.show()
# # Now, let's consider interpolating, especially if we see large deviations in the RR_idx_interval
# # THIS IS THE SECTION THAT I'D DEFINITELY NEED HELP ON, AS I'M PRETTY CONFUSED AND I'M NOT CONFIDENT THAT I'D DO IT RIGHT 
# RR_avg = np.mean(RR_idx_interval)
# arb_thres = 1.5
# counter = 0
# for ii in range(0, len(peak_idx)-1):
#     if RR_idx_interval[ii] > (arb_thres * RR_avg):          # a larger interval indicates that I need to interpolate
#         local_avg = np.mean(RR_idx_interval[(ii-5):ii]);
#         np.insert(RR_idx_interval, ii, local_avg);
#         # I'd also have to remove the troublesome interval value? 
#         counter = counter + 1

# plt.plot(RR_idx_interval); plt.show()
# ###
