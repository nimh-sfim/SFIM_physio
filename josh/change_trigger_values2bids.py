#!/usr/bin/env python

#python change_trigger_values2bids.py

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import os.path
import json

subjects=['sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19', 'sub20', 'sub21', 'sub22', 'sub23', 'sub24', 'sub25', 'sub26', 'sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34']
fileOI='outhold'
counter = 0

for subj_id in subjects:

    print('Processing ',subj_id)

    dir = '/data/SFIM_physio/physio/physio_files/'
    filepath = dir + subj_id + '/'
    filename = subj_id + '_' + fileOI + '_physio.tsv'
    filename_json = subj_id + '_' + fileOI + '_physio.json'
    json_file_to_access = dir + subj_id + '/' + filename_json
    file = os.path.join(filepath,filename)
    # file = filepath + '/' + filename     #'/raw_renamed/' + subj_id +'/' + filename     #needs to be relative path, absolute path does not work: file = filepath + '/' + filename
    if os.path.isfile(file):
        
        dframe = pd.read_table(file, delimiter='\t', header=None) 

        with open(json_file_to_access, 'r+') as f:
            data = json.load(f)
            trigger_idx_counter = 0
            for i in data['Columns']:
                if i == 'trigger':    #'Analog input'
                    trigger_idx = trigger_idx_counter
                    #print(i, trigger_idx)
                trigger_idx_counter += 1    #this is the variable that marks the index for which column 'trigger' belongs
                sf = data['SamplingFrequency']

        triggers = dframe.iloc[:,trigger_idx]

        triggers[triggers>4.9] = float(5.0)
        triggers[triggers<0.1] = float(0.0)

        #Here, I should save the triggers to the .tsv file
        counter = counter + 1
        output_file = filepath + subj_id + '_' + fileOI + '_physio.tsv'
        dframe.to_csv(output_file, sep='\t', index=False, header=False) 
        
        #print(counter)
        print(subj_id, 'is done processing')



#dframe.iloc[:,trigger_idx]=triggers

        # # Write the respective start time to the corresponding .json file
        # with open(filepath + '/' + filename_json, 'r+') as f:
        #     data = json.load(f)
        #     data['StartTime'] = start_time
        #     newData = json.dumps(data, indent=4)
        # with open(filepath + '/' + filename_json, 'w') as f:
        #     f.write(newData)




