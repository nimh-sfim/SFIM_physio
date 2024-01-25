#!/usr/bin/env python

#python change_column_names_json.py

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import os.path
import json

#excluding sub10 and sub19 for now
subjects=['sub17']   #['sub11' 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub20', 'sub21']
fileOI='Baseline'
counter = 0

for subj_id in subjects:

    filepath = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/' + subj_id + '/test/'
    filename_json = subj_id + '_' + fileOI + '_physio.json'
    file = os.path.join(filepath,filename_json)
    if os.path.isfile(file):
        
        with open(file, 'r+') as f:
            data = json.load(f)
            respiration_idx_counter = 0            	# 0: "TSD160A - Differential Pressure, 2.5 cm"
            cardiac_unfilt_idx_counter = 0          # 1: "PPG100C"
            trigger_idx_counter = 0                 # 2: "Analog input"
            cardiac_filt_idx_counter = 0            # 3: "C9 - PPGfiltered"
            for ii in data['Columns']:
                if ii == 'TSD160A - Differential Pressure, 2.5 cm':
                    respiration_idx = respiration_idx_counter
                respiration_idx_counter += 1    #this is the variable that marks the index for which column 'trigger' belongs
            for jj in data['Columns']:
                if jj == 'PPG100C':
                    cardiac_unfilt_idx = cardiac_unfilt_idx_counter
                cardiac_unfilt_idx_counter += 1    #this is the variable that marks the index for which column unfiltered cardiac belongs
            for kk in data['Columns']:
                if kk == 'Analog input':
                    trigger_idx = trigger_idx_counter
                trigger_idx_counter += 1    #this is the variable that marks the index for which column trigger belongs
            for ll in data['Columns']:
                if ll == 'C9 - PPGfiltered':
                    cardiac_filt_idx = cardiac_filt_idx_counter
                cardiac_filt_idx_counter += 1    #this is the variable that marks the index for which column *FILTERED* cardiac belongs (do use this column over unfiltered cardiac)

        print(respiration_idx)
        print(cardiac_unfilt_idx)
        print(trigger_idx)
        print(cardiac_filt_idx)

        # Write the respective start time to the corresponding .json file
        with open(file, 'r+') as f:
            data = json.load(f)
            data['Columns'][respiration_idx] = 'respiratory'
            data['Columns'][cardiac_unfilt_idx] = 'unfiltered'
            data['Columns'][trigger_idx] = 'trigger'
            data['Columns'][cardiac_filt_idx] = 'cardiac'
            newData = json.dumps(data, indent=4)
        with open(file, 'w') as f:
            f.write(newData)

        counter = counter + 1
        print(counter)

