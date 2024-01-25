# python normalize_acq_card.py

import bioread
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import json

subjects=['sub17']   #['sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub20', 'sub21']
fileOI='Resting'

for subjid in subjects:

    print(subjid + ' is processing')

    folder_dir = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/'
    data_dir = folder_dir + subjid + '/test/' + fileOI + '.acq'

    ### SAVE A NORMALIZED CARDIAC FILE ###

    data=bioread.read_file(data_dir)

    print(data.channels[3])     #check to make sure that the array's header is PPGfiltered
    filtered_card = data.channels[3].data
    plt.plot(filtered_card); plt.show()     #Let's also be plotting the before and after to just make sure nothing sus is going on
    med = abs(np.median(filtered_card))     #median may be negative, so to prevent flipping, take the absolute value 
    print(med)
    filtered_card_norm = (filtered_card / med) * 100        #normalize the ORIGINAL DATA s.t. the median is 100
    plt.plot(filtered_card_norm); plt.show()

    fname1 = folder_dir + subjid + '/test/' + subjid + '_' + fileOI + '_card_normalized.tsv'
    np.savetxt(fname1, filtered_card_norm, fmt='%.4f')       #round to fourth decimal place, as done automatically in physio2bidsphysio

    ### INPUT THE NORMALIZED CARDIAC FILE INTO THE PHYS .TSV FILE ###
    fname2 = folder_dir + subjid + '/test/' + subjid + '_' + fileOI + '_physio.tsv'
    phys_data = np.loadtxt(fname2)

    # Determine the index of the cardiac column 
    filepath = '/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/' + subjid + '/test/'
    filename_json = subjid + '_' + fileOI + '_physio.json'
    file_json = os.path.join(filepath,filename_json)
    if os.path.isfile(file_json):
        dframe = pd.read_table(file_json, delimiter='\t', header=None) 
        with open(file_json, 'r+') as f:
            data = json.load(f)
            cardiac_idx_counter = 0
            for i in data['Columns']:
                if i == 'cardiac':    #'Analog input'
                    cardiac_idx = cardiac_idx_counter
                cardiac_idx_counter += 1    #this is the variable that marks the index for which column 'cardiac' belongs

    phys_data[:,cardiac_idx] = filtered_card_norm       #replace the fourth column with the normalized cardiac data
    np.savetxt(fname2, phys_data, fmt='%.4f', delimiter='\t')           #overwrite the file

