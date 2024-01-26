clc;
clear;

%% Creation of Task Regressors

% path to data directory
directory = ['/Volumes/SFIM_physio/physio/'];
cd(directory)

counter = 1;
participant = ["20"];

for participant = participant
    %% Read in Data
    participant_folder = ['sub' (participant) '/'];
    prefix = ['sub' num2str(participant) '_bin_regr.tsv'];
    file = [directory participant_folder prefix];
    file1 = strjoin(file);           %has spaces
    file1 = strrep(file1,' ','');    %has no spaces
    
    data1 = readtable(file1,"FileType","text",'Delimiter','\t');
    
    %% Convolution (HiRes)
    % HRF Information
    fs = 100;
    t = 0:1/fs:25;
    HRF = exp(-t) .* ((0.00833333 .* t .^ 5) - (1.27e-13 .* t .^ 15));

    % Convolve signals
    data_conv = conv(data1,HRF);

    % Rescaling to the same units as unconvolved regressor
    data_conv_rs=rescale(rg_conv, min(data_conv),max(data_conv));
        
    % Demean
    data_conv_dm=data_conv_rs-mean(data_conv_rs);

    %% Downsample to trigger resolution
    trig = data1(:,2);
    
    % Sampling every sf*TR
    fs = 50;              % Sampling rate of input physiology file in Hz
    TR = 0.75;
    data_sml = data_conv_dm(1:fs*TR:end);
    
    %% Write data to txt files
    cd(directory);  
    prefix_no_ext = ['sub' num2str(participant) '_bin_regr_HRFconv'];      %no .txt
    writematrix(data_sml,['sub' num2str(participant) '/' prefix_no_ext '.txt']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    counter = counter + 1;
    
end



