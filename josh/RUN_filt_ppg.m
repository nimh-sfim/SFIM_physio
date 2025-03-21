% Runs the function, filt_ppg.m, that performs LFO and motion correction on
% BIOPAC's PPG trace.

% dependencies
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/load_acq'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))

taskOI = 'outhold';   % rest,inhold,outhold

%subjects = ["21"];
%subjects = ["12","13","14","15","16","18","19","20","21","22","23","24","25"];
%subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
subjects = ["27","28","30","31","32","33","34"];

perc_outliers_arr = [];

for ii = 1:length(subjects)
    sbjid = subjects(ii);

    dir1 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/physio/"],'');
    cd(dir1)
    
    % Define the number of volumes in fMRI dataset, specific to task & subject
    % To make this step faster, consider calling the HEADER instead of the NIFTI
    if strncmp(taskOI,'rest',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_rest/"],'');
    elseif strncmp(taskOI,'inhold',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_binh/"],'');
    elseif strncmp(taskOI,'outhold',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_bouh/"],'');
    end
    file = strjoin([dir2, "pb04.bp" sbjid ".r01.scale.nii"],'');
    
    if sbjid == "11" && strncmp(taskOI,'rest',4)
        nvols = 586;     %was cut short... See https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit?usp=sharing
    else
        nvols=get_nvols(convertStringsToChars(file));   %function only works with characters, not strings
    end
    scan_time=nvols*0.75;       %seconds
    
    % Sometimes the BIOPAC's sampling rate is 1000 Hz (for sub12 and sub13)
    if sbjid == "12" | sbjid == "13"
        fsamp = 1000;   %sampling rate for BIOPAC (ACQ data)
    else
        fsamp = 500;
    end
    
    %% Load BIOPAC ACQ
    dir3 = strjoin(["/data/SFIM_physio/physio/physio_files/sub" sbjid "/"],''); %Look into /physio parent folder because there are not consistent names in dir1 
    if strncmp(taskOI,'rest',4)
        fileList_acq = dir(fullfile(dir3, '*rest*.acq'));
    elseif strncmp(taskOI,'inhold',4)
        fileList_acq = fullfile(dir3, '*inhold.acq');
    elseif strncmp(taskOI,'outhold',4)
        fileList_acq = fullfile(dir3, '*outhold.acq');
    end
    theFiles_acq = dir(fileList_acq);
    
    theFiles_acq = dir(fileList_acq);       % Removes any hidden files from consideration (this is for sub10 specifically)
    isBadFile = cat(1,theFiles_acq.isdir);  % All directories are bad
    for iFile = find(~isBadFile)'           % Loop only non directories to identify hidden files 
       isBadFile(iFile) = strcmp(theFiles_acq(iFile).name(1),'.');  % Hidden files start with a dot
    end
    theFiles_acq(isBadFile) = [];           % Remove bad files
    myacq = load_acq(strjoin([dir3, theFiles_acq.name],''));
    
    dir4 = "/data/SFIM_physio/scripts/";
    cd(dir4)
    flow=0.01;fhigh=0.1;
    bp_chosen=myacq.data(1:(scan_time)*fsamp,2);%biopac chosen segment of PPG
    %ts_out = filt_ppg(bp_chosen,flow,fhigh,fsamp);
    [perc_outliers, ts_out] = filt_ppg(bp_chosen,flow,fhigh,fsamp);

    figure(ii)
    plot(bp_chosen-mean(bp_chosen)); hold on
    plot(ts_out,'LineWidth',2);legend('orig','clean');
    title(sbjid)
    % xlim([150000 450000]);ylim([-0.2 0.2]);
    % xlim([80000 200000]);ylim([-0.6 0.6]);

    disp(['percentage of trace that was above or below 2 stdev: ', num2str(perc_outliers)])
    perc_outliers_arr = [perc_outliers_arr; perc_outliers];

    %% Save variable... 
    dir5 = strjoin(["/data/SFIM_physio/physio/physio_results/sub" sbjid "/"],'');
    cd(dir5)
    filename2save = strjoin(["sub" sbjid "_lfo_" taskOI ".tsv"],'');
    writematrix(ts_out, filename2save,'filetype','text', 'delimiter','\t')

end
