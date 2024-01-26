## Creation of Task Regressors, convolved with HRF 

import pandas as pd
import numpy as np
import math
import matplotlib.pyplot as plt

# path to data directory
directory = '/Volumes/SFIM_physio/physio/';

counter = 1;
counter2 = 1;
participants = ['20'];

for participant in participants:
    ## Read in Data
    participant_folder = 'sub' + participant + '/'
    prefix = 'sub' + participant + '_bin_regr.tsv';
    file = directory + participant_folder + prefix;
    
    data1 = pd.read_csv(file,sep='\t')
    data1 = np.reshape(data1, data1.size)   #flatten into a 1D array

    ## Convolution (HiRes)
    # HRF Information
    fs = 100;
    t = np.arange(start=0,stop=25,step=1/fs);
    HRF = np.zeros(len(t));
    for ii in t:
        HRF[counter2-1] = math.exp(-ii) * ((0.00833333 * (ii ** 5)) - (1.27e-13 * (ii ** 15)))
        counter2 = counter2 + 1

    # Convolve signals
    data_conv = np.convolve(data1,HRF);

    # Rescaling to the same units as unconvolved regressor
    data_conv_rs=rescale(data_conv, min(data_conv),max(data_conv));
        
    # Demean
    data_conv_dm=data_conv_rs-mean(data_conv_rs);

    ## Downsample to trigger resolution
    trig = data1(:,2);
    
    # Sampling every sf*TR
    fs = 50;              # Sampling rate of input physiology file in Hz
    TR = 0.75;
    data_sml = data_conv_dm(1:fs*TR:end);
    
    ## Write data to txt files
    cd(directory);  
    prefix_no_ext = ['sub' num2str(participant) '_bin_regr_HRFconv'];      #no .txt
    writematrix(data_sml,['sub' num2str(participant) '/' prefix_no_ext '.txt']);

    #######################################################################

    counter = counter + 1;
    

