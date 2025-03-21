# python normalize_acq_card.py
# python /data/SFIM_physio/scripts/normalize_acq_card.py

import bioread
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import json

#'sub10', 'sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19', 'sub20', 'sub21', 'sub22', 'sub23', 'sub24', 'sub25'
#subjects=['sub26', 'sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34']
subjects=['sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19', 'sub20', 'sub21', 'sub22', 'sub23', 'sub24', 'sub25', 'sub26', 'sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34']
#subjects=['sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', 'sub33', 'sub34']
fileOI='outhold'

#######
for subjid in subjects:

    print(subjid + ' is processing')

    folder_dir = '/data/SFIM_physio/physio/physio_files/'
    data_dir = folder_dir + subjid + '/' + subjid + '_' + fileOI + '.acq'

    # Determine the index of the cardiac column 
    filepath = '/data/SFIM_physio/physio/physio_files/' + subjid + '/'
    filename_json = subjid + '_' + fileOI + '_physio.json'
    file_json = os.path.join(filepath,filename_json)
    if os.path.isfile(file_json):
        dframe = pd.read_table(file_json, delimiter='\t', header=None) 
        with open(file_json, 'r+') as f:
            json_data = json.load(f)
            cardiac_idx_counter = 0
            for i in json_data['Columns']:
                if i == 'cardiac':    #'Analog input'
                    cardiac_idx = cardiac_idx_counter
                cardiac_idx_counter += 1    #this is the variable that marks the index for which column 'cardiac' belongs

    ### SAVE A NORMALIZED CARDIAC FILE ###
    data=bioread.read_file(data_dir)
    # print(data.channels[3])     #check to make sure that the array's header is PPGfiltered
    print('cardiac index is', cardiac_idx)     #check to make sure that the array's header is PPGfiltered --> should be index 3 (column 4)
    card_data = data.channels[cardiac_idx].data
    plt.plot(card_data); plt.title('filtered card'); plt.show()

    med = abs(np.median(card_data))     #median may be negative, so to prevent flipping, take the absolute value 
    card_norm = (card_data / med) * 100        #normalize the ORIGINAL DATA s.t. the median is 100
    plt.plot(card_norm); plt.show()

    fname1 = folder_dir + subjid + '/' + subjid + '_' + fileOI + '_card_normalized.tsv'
    np.savetxt(fname1, card_norm, fmt='%.4f')       #round to fourth decimal place, as done automatically in physio2bidsphysio

    ### INPUT THE NORMALIZED CARDIAC FILE INTO THE PHYS .TSV FILE ###
    fname2 = folder_dir + subjid + '/' + subjid + '_' + fileOI + '_physio.tsv'
    phys_data = np.loadtxt(fname2)
    phys_data[:,cardiac_idx] = card_norm       #replace the fourth column with the normalized cardiac data
    np.savetxt(fname2, phys_data, fmt='%.4f', delimiter='\t')           #overwrite the file

