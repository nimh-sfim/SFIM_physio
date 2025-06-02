% This script determines which subject-task pairs had particularly low
% cross correlations between the CareTaker pulse and BIOPAC's PPG data

clear

% dependencies
addpath(genpath('/Volumes/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/Volumes/SFIM/akin/bin/load_acq'))
addpath(genpath('/Volumes/SFIM/akin/bin/burak/'))
addpath(genpath('/Volumes/SFIM_physio/dependencies/Scattered Data Interpolation and Approximation using Radial Base Functions'))

taskOI = 'outhold';   % inhold,outhold,resting
subjects = ["11"];
max_corrs_across_subjects = [];
subjects_included4corr = [];
corr_indices = [];

for ii = 1:length(subjects)
    sbjid = subjects(ii);
    
    % Load Pulse Resampled caretaker (tsv data)
    dir1 = strjoin(["/Volumes/SFIM_physio/physio/physio_results/sub" sbjid "/"],'');
    pulse_resamp_filename = strjoin(["sub" sbjid "_pulse_csv_resampled.tsv"],'');
    pulse_resamp = readtable(strjoin([dir1, "/", pulse_resamp_filename],''), "FileType","text",'Delimiter', '\t');
    
    % Load Biopac (acq data)
    dir2 = strjoin(["/Volumes/SFIM_physio/physio/physio_files/sub" sbjid "/"],''); %Look into /physio parent folder because there are not consistent names in dir1 
    if strncmp(taskOI,'rest',4)
        fileList_acq = dir(fullfile(dir2, '*rest*.acq'));
    elseif strncmp(taskOI,'inhold',4)
        fileList_acq = fullfile(dir2, '*inhold.acq');
    elseif strncmp(taskOI,'outhold',4)
        fileList_acq = fullfile(dir2, '*outhold.acq');
    end
    
    filename_acq = strjoin(["sub" sbjid "_" taskOI ".acq"],'');
    myacq = load_acq(strjoin([dir2, filename_acq],''));
    
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
    
    % Question: not sure if sbjid 11's inhold or outhold scans (or phys traces) are shorter
    % as well. Look into this
    % Subject 11's resting scan was cut short, so set nvols accordingly
    %if sbjid == "11" && strncmp(taskOI,'rest',4)
    if sbjid == "11" && strncmp(taskOI,'rest',4)
        nvols = 586;     %See https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit?usp=sharing
    elseif sbjid == "11" && strncmp(taskOI,'inhold',4) %double check to make sure inhold is indeed shorter!
        nvols = 586;
    end
    scan_time=nvols*0.75;       %seconds
    
    % Sometimes the BIOPAC's sampling rate is 1000 Hz (for sub12 and sub13)
    if sbjid == "12" | sbjid == "13"
        fsamp_biopac = 1000;   %sampling rate for BIOPAC (ACQ data)
    else
        fsamp_biopac = 500;
    end
    fsamp_pulse = 32; 
    
    bp_chosen=myacq.data(1:(scan_time)*fsamp_biopac,2);
    
    %% Before Correlating, let's filter the BIOPAC and CareTaker data to 
    % remove the non-pulsatile, lower frequency components; Pulsatile components starts around 1 Hz

    % First, let's HPF the BIOPAC data.
    fc = 0.4;                   % Cut-off frequency (Hz)
    Wn = fc/(fsamp_biopac/2);   % Normalize cutoff frequency
    filt_order = 4;
    [b, a] = butter(filt_order, Wn, 'high');        % Design a Butterworth low-pass filter
    bp_chosen_filt = filtfilt(b, a, bp_chosen);     % Apply the filter to your data using zero-phase filtering

    ylim_max = 1500;
    t = tiledlayout(5,2);
    nexttile
    f = (0:length(bp_chosen_filt)-1)*fsamp_biopac/length(bp_chosen_filt);
    bp_chosen_filt_fft = fft(bp_chosen_filt);
    plot(f,abs(bp_chosen_filt_fft))
    title('Power spectra of post HP filtered BIOPAC data')
    xlim([0 1]); ylim([0 ylim_max]); ylabel('HP filtered PPG')
    nexttile
    f = (0:length(bp_chosen)-1)*fsamp_biopac/length(bp_chosen);
    bp_chosen_fft = fft(bp_chosen);
    plot(f,abs(bp_chosen_fft))
    xlim([0 1]); ylim([0 ylim_max]); ylabel('non-filtered PPG')
    title('Power spectra of pre HP filtered BIOPAC data')
    
    % Now, let's HPF the CareTaker pulse data.

    pulse_resamp_arr = table2array(pulse_resamp(:,2));

    Wn = fc/(fsamp_pulse/2);    %Normalize cutoff frequency
    filt_order = 4;
    [b, a] = butter(filt_order, Wn, 'high');  %Design a Butterworth low-pass filter
    pulse_resamp_arr_filt = filtfilt(b, a, pulse_resamp_arr);  %Apply the filter to your data using zero-phase filtering

    nexttile
    f = (0:length(pulse_resamp_arr_filt)-1)*fsamp_biopac/length(pulse_resamp_arr_filt);
    pulse_resamp_arr_filt_fft = fft(pulse_resamp_arr_filt);
    plot(f,abs(pulse_resamp_arr_filt_fft))
    xlim([0 40]); ylabel('HP filtered CareTaker'); xlabel('I doubt units are in Hz? But actually not sure why looks cuts off at 40 instead, if they are? I changed the ltiview...')
    title('Power spectra of post HP filtered CareTaker Pulse data')
    nexttile
    f = (0:length(pulse_resamp_arr)-1)*fsamp_biopac/length(pulse_resamp_arr);
    pulse_resamp_arr_fft = fft(pulse_resamp_arr);
    plot(f,abs(pulse_resamp_arr_fft))
    xlim([0 40]); ylabel('non-filtered CareTaker'); xlabel('I doubt units are in Hz? But actually not sure why looks cuts off at 40 instead, if they are? I changed the ltiview...')
    title('Power spectra of pre HP filtered CareTaker Pulse data')

    nexttile;
    plot(bp_chosen_filt, 'DisplayName', 'HPF'); hold on; plot(bp_chosen, 'DisplayName', 'OG'); legend(); ylabel('BIOPAC'); title('BIOPAC trace after HPF')
    nexttile; 
    plot(pulse_resamp_arr_filt, 'DisplayName', 'HPF'); hold on; plot(pulse_resamp_arr, 'DisplayName', 'OG'); legend(); ylabel('CareTaker'); title('CareTaker pulse trace after HPF')

    %% Now, let's correlate the HP filtered BIOPAC and HPF CareTaker Pulse traces
    dt_pulse = 31.25;
    scaling_fac1 = fsamp_biopac/dt_pulse;   %Scaling factor to go from sampling space of BIOPAC's PPG data to CareTaker's pulse data
    bp_match=interp1(linspace(0,1,length(bp_chosen_filt)),bp_chosen_filt,linspace(0,1,length(bp_chosen_filt)/scaling_fac1));
    
    ct_chosen=pulse_resamp_arr_filt;
    
    % xcorr between caretaker recording, ct_chosen, and pulse oximeter (ACQ), bp_match
    clear cval
    for xx=1:(length(ct_chosen)-length(bp_match))
        cval(xx)=corr(ct_chosen((0+xx):(xx-1+length(bp_match))),bp_match');
    end
    [hh,jj]=max(cval);      %[xcorr val, index]

    % THIS IS MAYBE WHERE YOU PUT THE WARNING OF THE LOW CROSS CORRELATION
    % AND DO MANUAL CORRECTION?
    if hh < 0.5
        disp(strjoin(['WARNING: SUB' sbjid ' HAS A LOW XCORR (=' hh ') BW PPG AND CARETAKER.'],'')); disp('MAY REQUIRE MANUAL SYNCHRONIZATION.')
    end
    % HAVEN'T YET CHECKED TO SEE IF THIS WORKS ^ 

    ct_match=ct_chosen((1+jj-1):(1+jj-2+length(bp_match)));
    
    nexttile
    plot(cval); title('cross corr values between bpmatch and ctmatch')
    nexttile
    plot(demean(bp_match)/std(bp_match), 'DisplayName', 'BIOPAC'); hold on; plot(demean(ct_match)/std(ct_match), 'DisplayName', 'Matched CareTaker Pulse'); legend();
    title('bpmatch and ctmatch timeseries aligned')
    
    % Let's just generally see which subjects will be the most trouble to generate the cropped MAP data... 
    subjects_included4corr = [subjects_included4corr; sbjid];
    max_corrs_across_subjects = [max_corrs_across_subjects; hh];
    corr_indices = [corr_indices; jj];
    xcorr_sbjs_table = [subjects_included4corr, max_corrs_across_subjects, corr_indices];
    
end

xcorr_sbjs_table = table(xcorr_sbjs_table);
xcorr_sbjs_table = splitvars(xcorr_sbjs_table);
xcorr_sbjs_table.Properties.VariableNames( [1 2 3] ) = [{'Subjects'}, {taskOI}, {'Automated Index'}];
