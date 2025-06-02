%From the resampled CareTaker pulse and vitals data, synchronize
%the BIOPAC and CareTaker pulse data, and use that synchronized time index
%to extract and crop the vitals data, which stores the blood pressure
%values calculated in-house by the CareTaker system. 
%Variable naming convention: bp is Biopac (originally ACQ), AND ct is caretaker (originally CSV)
%Naming convention by device: bp is BIOPAC; ct is caretaker. i.e., bp is NOT blood pressure

clear

%% Now that the Caretaker (vitals and pulse CSV's) are synchronized and 
% re-sampled to even sampling grids, let's synchronize the CareTaker data 
% to the BIOPAC data, then crop to generate the resting and breathing task 
% MAP data. 

% dependencies
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/load_acq'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))
addpath(genpath('/data/SFIM_physio/dependencies/Scattered Data Interpolation and Approximation using Radial Base Functions'))

taskOI = 'outhold';   % resting,inhold,outhold
max_corrs_across_subjects = [];
subjects_included4corr = [];
corr_indices = [];

subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
%subjects = ["10", "11"];

% change to 2 while loops instead of 1 while and 1 for loop. Don't want two ii's going

% for loop catches the break
% this was helpful for starting to determine what I wanted to do wrt for
% and while loops: https://www.mathworks.com/matlabcentral/answers/353141-return-to-previous-step#comment_478083

ii = 1;     % initialize

while ii <= length(subjects)
%for ii = 1:length(subjects)
%while is_data_synchronizable    %some subjects are not able to be synchronized
    %fprintf('im in while loop 1 now. ii: %f \n', ii)

    is_data_synchronizable = true;  %by default, set to true to run the processing

    while is_data_synchronizable    %some subjects are not able to be synchronized
    %for ii = 1:length(subjects)
        %fprintf('im in while loop 2 now. ii: %f \n', ii)

        sbjid = subjects(ii);
    
        % Some subjects didn't have phys data. Skip these.
        if sbjid == "10" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No breathing ACQ.'],''))
            is_data_synchronizable = false;      % don't continue processing and go to next subject
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "10" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No breathing ACQ.'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break 
        elseif sbjid == "26" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No Inhold ACQ.'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break           
        end
    
        % Load Pulse Resampled caretaker (tsv data)
        dir1 = strjoin(["/data/SFIM_physio/physio/physio_results/sub" sbjid "/"],'');
        pulse_resamp_filename = strjoin(["sub" sbjid "_pulse_csv_resampled.tsv"],'');
        pulse_resamp = readtable(strjoin([dir1, "/", pulse_resamp_filename],''), "FileType","text",'Delimiter', '\t');
        
        % Load Vitals Upsampled caretaker (tsv data)
        vitals_upsamp_filename = strjoin(["sub" sbjid "_vitals_csv_upsampled.tsv"],'');
        vitals_upsamp = readtable(strjoin([dir1, "/", vitals_upsamp_filename],''), "FileType","text",'Delimiter', '\t');
    
        % Load Biopac (acq data)
        dir2 = strjoin(["/data/SFIM_physio/physio/physio_files/sub" sbjid "/"],''); %Look into /physio parent folder because there are not consistent names in dir1 
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
        nvols_table = readtable('/data/SFIM_physio/scripts/nifti_volumes.txt');
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
            fsamp_biopac = 1000;   %sampling rate for BIOPAC (ACQ data)
        else
            fsamp_biopac = 500;
        end
        fsamp_pulse = 32; 
        fsamp_vitals = 10;
        
        bp_chosen=myacq.data(1:(scan_time)*fsamp_biopac,2);     %column 2 from ACQ data is "unfiltered" (PPG) column.
    
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
    
        if hh < 0.5
            disp(strjoin(['WARNING: SUB' sbjid ' HAS A LOW XCORR (=' hh ') BW PPG AND CARETAKER.'],'')); disp('MAY REQUIRE MANUAL SYNCHRONIZATION.')
        end
    
        %% There are instances where I manually checked whether our cross correlation approach for synchronization was working
        % The following are these instances, and I note the decision for each of the exceptions. 
        if sbjid == "11" && strncmp(taskOI,'rest',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "14" && strncmp(taskOI,'rest',4)
            hh = 108966;
            disp(['Changed hh to ' num2str(hh) '.'])
        elseif sbjid == "25" && strncmp(taskOI,'rest',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;      % don't continue processing and go to next subject
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "28" && strncmp(taskOI,'rest',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "32" && strncmp(taskOI,'rest',4)
            hh = 94332;
            disp(['Changed hh to ' num2str(hh) '.'])
        elseif sbjid == "33" && strncmp(taskOI,'rest',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "12" && strncmp(taskOI,'inhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "28" && strncmp(taskOI,'inhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "33" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "12" && strncmp(taskOI,'outhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "22" && strncmp(taskOI,'outhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "24" && strncmp(taskOI,'outhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "25" && strncmp(taskOI,'outhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "28" && strncmp(taskOI,'outhold',4)
            disp('yeah, nevermind, ignore the warning. Its optimal')
        elseif sbjid == "31" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            disp('*Note: Im unsure whether index should be changed to 73184. Atm, Im choosing to not proceed.')
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "33" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        end
    
        ct_match=ct_chosen((1+jj-1):(1+jj-2+length(bp_match)));
        
        nexttile
        plot(cval); title('cross corr values between bpmatch and ctmatch')
        nexttile
        plot(demean(bp_match)/std(bp_match), 'DisplayName', 'BIOPAC'); hold on; plot(demean(ct_match)/std(ct_match), 'DisplayName', 'Matched CareTaker Pulse'); legend();
        title('bpmatch and ctmatch timeseries aligned')
    
        %% Synchronize the CareTaker vitals and pulse datasets
    
        %make sure that you consider that the index for vitals and pulse aren't
        %going to be the same! Vitals' first time point is different than
        %pulse's first time point
        
        vitals_upsamp_arr = table2array(vitals_upsamp);
    
        %jj is the index from ct_chosen that defined ct_match: Checking for sanity's sake... 
        %plot(ct_chosen(jj:(jj+length(ct_match))),'.'); hold on; plot(ct_match,'-');
        
        % the time that we want to match to CareTaker's vitals
        time_of_interest = table2array(pulse_resamp(jj,1));
    
        % This doesn't quite work because the decimals in vitals_upsamp's time
        % column (1) can go beyond the tenths place, as is the case in ct_match
        % (CareTaker's pulse).
        idx_OI = min(find(round(vitals_upsamp_arr(:,1))==round(time_of_interest)));
        % So, I'm now considering to resample vitals_resamp to be in the same
        % time as the Pulse, and that way the indices would also match! 
    
        % Recall that vitals has sampling of 10
        % and that pulse has sampling of 32
        
        % okie dokie, so let's first define the timepoints  that we'll want to
        % interpolate from Pulse to Vitals
        pulse_resamp_timing = table2array(pulse_resamp(:,1));
        t4 = [pulse_resamp_timing(jj) : (1/fsamp_pulse) : (pulse_resamp_timing(jj) + scan_time - 1/fsamp_pulse)];
    
        % Create coordinates of nodes
        t5 = [t4(1) : (1/fsamp_vitals) : t4(end)];
    
        % Column 4 of Vitals table is MAP. Later, make a check for this
        % Check to make sure that the column names are consistent with my expectations
        expected_col_names = ["Time","Systolic_mmHg_","Diastolic_mmHg_","MAP_mmHg_"];
        for kk = 1:length(vitals_upsamp.Properties.VariableNames)
            if strcmp(vitals_upsamp.Properties.VariableNames(kk),expected_col_names(kk)) == 0
                disp(['WARNING: COLUMN NAMES OF VITALS DO NOT MEET MY EXPECTATIONS, index: ', num2str(kk), '.']); disp('THIS MAY INDICATE THAT MAP DATA IS NOT THE COLUMN BEING EXTRACTED.')
            end
        end
        
        % Create values of function at the nodes
        vitals_val_nodes = vitals_upsamp_arr([idx_OI:(idx_OI+(scan_time*fsamp_vitals)-1)], 4);
    
        %% Now, interpolate the Vitals to this timing information using RBF
        smooth_factor = 0;
        rbf_map = rbfcreate(t5,vitals_val_nodes','RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
        
        % Calculate interpolated values
        fi_map = rbfinterp(t4, rbf_map);
    
        nexttile    %at the moment, there should be 9 tiles.
        plot(fi_map); title('MAP that has been synchronized to corresponding BIOPAC')
    
        %% Save variable, fi_map... 
        cd(dir1)
        MAP_upsampled = array2table([t4; fi_map]');
        MAP_upsampled.Properties.VariableNames = [vitals_upsamp.Properties.VariableNames(1) vitals_upsamp.Properties.VariableNames(4)];
        filename2save = strjoin(["sub" sbjid "_MAP_upsampled_" taskOI ".tsv"],'');
        writetable(MAP_upsampled, filename2save,'filetype','text', 'delimiter','\t')
        
        %% Save the figures altogether as one .fig so that we can go back and look 
        % through them to make sure they look okay. I'm planning on making all
        % the MAP files at once in a loop. 
        title(t, "sub" + sbjid)
        fig_filename = strjoin(["sub" sbjid "_" taskOI "_synch_cropping_MAP_ts_process.fig"],'');
        savefig(fig_filename)
        
        % Quality Check: Make sure this matches with the correct outcomes
        subjects_included4corr = [subjects_included4corr; sbjid];
        max_corrs_across_subjects = [max_corrs_across_subjects; hh];
        corr_indices = [corr_indices; jj];
        xcorr_sbjs_table = [subjects_included4corr, max_corrs_across_subjects, corr_indices];
        
        is_data_synchronizable = true;  %by default, set to true to run the processing
        
        if ii == length(subjects)
            ii = ii+1;  % otherwise will re-do the subject
            break       % indicates that we've reached the end of the subject list
        end
        
        ii = ii+1;      %increase while in for loop. Otherwise will continue to do the same subject.

    end
end

xcorr_sbjs_table = table(xcorr_sbjs_table);
xcorr_sbjs_table = splitvars(xcorr_sbjs_table);
xcorr_sbjs_table.Properties.VariableNames( [1 2 3] ) = [{'Subjects'}, {taskOI}, {'Automated Index'}];




% For CareTaker, 31.25 ms is the period between samples
% AKA, 32 Hz is the sampling rate!

% dir2 = strjoin(["/data/SFIM_physio/physio/physio_files/sub" sbjid "/"],''); %Look into /physio parent folder because there are not consistent names in dir1 
% if strncmp(taskOI,'rest',4)
%     fileList_acq = dir(fullfile(dir2, '*rest*.acq'));%Rest
% elseif strncmp(taskOI,'inhold',4)
%     fileList_acq = fullfile(dir2, '*inhold.acq');
% elseif strncmp(taskOI,'outhold',4)
%     fileList_acq = fullfile(dir2, '*outhold.acq');
% end
% theFiles_acq = dir(fileList_acq);
% 
% theFiles_acq = dir(fileList_acq);       % Removes any hidden files from consideration (this is for sub10 specifically)
% isBadFile = cat(1,theFiles_acq.isdir);  % All directories are bad
% for iFile = find(~isBadFile)'           % Loop only non directories to identify hidden files 
%    isBadFile(iFile) = strcmp(theFiles_acq(iFile).name(1),'.');  % Hidden files start with a dot
% end
% theFiles_acq(isBadFile) = [];           % Remove bad files
% 
% myacq = load_acq(strjoin([dir2, theFiles_acq.name],''));
