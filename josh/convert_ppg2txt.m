% This script saves PPG data as .txt, so that we can manipulate the data
% using bash (ACQ is difficult to handle)

%% Dependencies
addpath(genpath('/Volumes/SFIM/akin/bin/load_acq'))
addpath(genpath('/Volumes/SFIM/akin/bin/burak/'))

%% First, let's save the PPG trace as a .txt file for 3dToutcount to read from my bash script, RUN_censor.sh

taskOI = 'outhold';   % resting,inhold,outhold
subjects = ["29"]
%subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","27","28","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);
    
    dir2 = strjoin(["/Volumes/SFIM_physio/physio/physio_files/sub" sbjid "/"],'');
    filename_acq = strjoin(["sub" sbjid "_" taskOI ".acq"],'');
    myacq = load_acq(strjoin([dir2, filename_acq],''));
    acq_data = myacq.data;
    ppg = acq_data(:,2);
    plot(ppg); title(strjoin(["sub" sbjid " " taskOI],''));
    
    %% Let's determine the nvols from the text file instead of reading in the NIFTI file
    nvols_table = readtable('/Volumes/SFIM_physio/scripts/nifti_volumes.txt');
    nvols_sbj = nvols_table(:,1);
    nvols_task = nvols_table.Properties.VariableNames(2:4);
    
    expected_col_names = ["Subjects","bouh","binh","rest"];
    for kk = 1:length(nvols_table.Properties.VariableNames)
        if strcmp(nvols_table.Properties.VariableNames(kk),expected_col_names(kk)) == 0
            disp(['WARNING: COLUMN NAMES OF NVOLS TABLE DO NOT MEET MY EXPECTATIONS, index: ', num2str(kk), '.']); disp('THIS MAY INDICATE THAT IM USING THE WRONG NVOLS.')
        end
    end
    
    if strncmp(taskOI, 'outhold', 4)
        colOI = 2;      %task_tmp = 'bouh'
    elseif strncmp(taskOI, 'inhold', 4)
        colOI = 3;      %task_tmp = 'binh'
    elseif strncmp(taskOI, 'rest', 4)
        colOI = 4;      %task_tmp = 'rest'
    end
    rowOI = str2num(sbjid) - 10 + 1;
    nvols = table2array(nvols_table(rowOI, colOI));
    
    % Three phys datas were cut short, so set nvols accordingly
    if sbjid == "11" && strncmp(taskOI,'rest',4)
        nvols = 586;
    elseif sbjid == "11" && strncmp(taskOI,'inhold',4)
        nvols = 586;
    elseif sbjid == "26" && strncmp(taskOI,'outhold',4)
        nvols = 586;
    end
    scan_time=nvols*0.75;       %seconds

    %% Sometimes the BIOPAC's sampling rate is 1000 Hz (for sub12 and sub13)
    if sbjid == "12" | sbjid == "13"
        fsamp = 1000;   %sampling rate for BIOPAC (ACQ data)
    else
        fsamp = 500;
    end
    
    %%
    flow=0.01;
    fhigh=0.1;
    bp_chosen=myacq.data(1:(scan_time)*fsamp,2);%biopac chosen segment of PPG
    timeseries=bp_chosen;
    plot(timeseries)

    timeseries_ds = decimate(timeseries, 50);
    dir3 = strjoin(["/Volumes/SFIM_physio/physio/physio_results/sub" sbjid "/"],'');
    cd(dir3)
    writematrix(timeseries_ds, strjoin(["sub" sbjid "_" taskOI "_ppg.txt"],''), 'Delimiter','tab')

end
