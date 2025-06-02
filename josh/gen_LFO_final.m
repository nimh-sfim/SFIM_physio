% Now that I've generated the PPG text files using convert_ppg2txt.m and 
% having called the RUN_censor.sh script, I'll..
% 1. Demean and HPF (fc=0.01) the PPG trace
% 2. Manually change width of censoring-indice-boxcar vector
% 3. Save this boxcar vector
% 4. LPF the PPG trace

% Subjects skipping (only for now, come back to it):
%1. sub25 resting -- even the clean portions seem noisy. Perhaps the
%non-pulsatile component is still reliable though, so return back to this.
%2. sub25 outhold

%% Dependencies and Define Inputs
clc;clear;
addpath(genpath('/Volumes/SFIM/akin/bin/load_acq'))
addpath(genpath('/Volumes/SFIM/akin/bin/burak/'))

taskOI = 'outhold';   % resting,inhold,outhold
subjects = ["34"];
ii=1; sbjid = subjects(ii);
flow=0.01;
fhigh=0.1;

dir1 = strjoin(["/Volumes/SFIM_physio/physio/physio_files/sub" sbjid "/"],'');
filename_acq = strjoin(["sub" sbjid "_" taskOI ".acq"],'');
myacq = load_acq(strjoin([dir1, filename_acq],''));
acq_data = myacq.data;
ppg = acq_data(:,2);
plot(ppg); title(strjoin(["sub" sbjid " " taskOI " -- NOT YET TRIMMED"],''));

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

%% Load the boxcar to determine censoring
dir3 = strjoin(["/Volumes/SFIM_physio/physio/physio_results/sub" sbjid "/"],'');
censor = load(strjoin([dir3 "/sub" sbjid "_" taskOI "_censor.1D"],''));
if sbjid == "12" | sbjid == "13"
    ts_orig = [1/20:1/20:scan_time]';
else
    ts_orig = [1/10:1/10:scan_time]';
end
ts_new = [1/fsamp:1/fsamp:scan_time]';
censor_ups = interp1(ts_orig ,censor, ts_new);
censor_ups(censor_ups ~= 0) = 1;  % %There's a ramp up/down when interpolating. Set all non-zero values to 1.

%% Trim, detrend, then remove median
ppg_tm = ppg(1:(scan_time*fsamp));
ppg_tm2 = detrend(ppg_tm, 3);
ppg_tm2 = detrend(ppg_tm2, 2);
ppg_tm2 = detrend(ppg_tm2, 1);
ppg_dm = ppg_tm2-(median(ppg_tm2));

tiledlayout(2,1); nexttile;
plot(ppg_dm); title('PPG demeaned'); nexttile;
plot(censor_ups); title('Counts of where large spikes detected by 3dToutcount')

ts_detrend_tmp = ppg_dm;   %Make a temporary array where I'll be making the changes of correcting spikes
censor_ups_tmp = censor_ups;

% Detrend instead of HPF? <-- tentatively yes. There was an instability
% introduced by sub15resting from the HPF.

%% Manually correct the boxcar censoring segments as detected by 3dToutcount
% Before manually correcting spikes, first, let's plot to identify where, if any, there are large spikes
plot(ts_detrend_tmp,'LineStyle','-.','DisplayName','ts detrend'); 
hold on; plot(censor_ups_tmp, 'DisplayName','Boxcar');
hold on; plot(ppg_dm,'DisplayName','PPG dm'); legend();

% Censor out large spikes via manual correction by expanding boxcar widths
idx1 = 1;       %where does the spike start
idx2 = 304;       %where does the spike end
boxcar_val = 0;      %1 if censor, 0 is don't censor
hold on; xline(idx1); hold on; xline(idx2);     %Make sure these lines appear where I intend

% What the new boxcar widths look like on top of PPG and ts_detrend
censor_ups_tmp([idx1:idx2]) = boxcar_val;
ts_detrend_tmp(censor_ups_tmp == 1) = 0;
clf; plot(ppg_dm((idx1-5000):(idx2+5000)), 'DisplayName','PPG dm'); 
hold on; plot(censor_ups((idx1-5000):(idx2+5000)), 'DisplayName','Old Boxcar','LineStyle','-.')
hold on; plot(censor_ups_tmp((idx1-5000):(idx2+5000)), 'DisplayName','New Boxcar')
hold on; plot(ts_detrend_tmp((idx1-5000):(idx2+5000)), 'DisplayName','Step pre-LFO','LineStyle','-.','LineWidth',2,'Color','g')
legend;

% Now, go back up and do it again, as needed. If not, continue forward. 
% Let's make sure that what we have looks good before moving on. 
plot(ts_detrend_tmp); hold on; plot(censor_ups_tmp, 'LineStyle', '-.');

% Save from temp to mancor files
censor_ups_mancor = censor_ups_tmp;
ts_detrend_mancor = ppg_dm;         % Don't do ts_detrend_tmp, because I've been changing it above and it also reflects the automatic spikes detected by 3dToutcount, which was sometimes incorrect in its detection.
ts_detrend_mancor(censor_ups_mancor == 1) = 0;
plot(ts_detrend_mancor)

% Change to physio results folder
dir2="/Volumes/SFIM_physio/physio/physio_results/";
folder2 = strjoin([dir2,"sub",sbjid,"/"],'');
cd(folder2);

% Write data to tsv files
prefix1 = ['sub' sbjid '_' taskOI '_censor_mancor'];     %mancor = manually corrected
filename2save1 = strjoin([folder2 prefix1 '.tsv'],'');
writematrix(censor_ups_mancor,filename2save1,'filetype','text','delimiter','\t');

prefix2 = ['sub' sbjid '_' taskOI '_ts-detrend_censor_mancor'];
filename2save2 = strjoin([folder2 prefix2 '.tsv'],'');
writematrix(ts_detrend_mancor,filename2save2,'filetype','text','delimiter','\t');

%% The LFO
% now do actual filtering low pass
N=2;
Wlo=fhigh/(fsamp/2);
[B2,A2]=butter(N,Wlo,'low');
ts_out=filtfilt(B2,A2,ts_detrend_mancor);

%% Plotting all four
t = tiledlayout(4,1); nexttile;
plot(ts_detrend_mancor); hold on; plot(ts_out, 'LineWidth', 2); title('Censored PPG and LFO'); nexttile;
plot(ppg_dm); title('Uncensored, PPG demeaned'); nexttile;
plot(censor_ups_mancor); title('Manually corrected boxcar to censor spikes'); nexttile;
plot(ts_out); title('LFO')

title(t, "sub" + sbjid + " " + taskOI + " - making the LFO")
fig_filename = strjoin(["sub" sbjid "_" taskOI "_generating_the_LFO.fig"],'');
savefig(fig_filename)       % save plot for QC

%% Save LFO as .tsv
prefix3 = ['sub' sbjid '_lfo_' taskOI];
filename2save3 = strjoin([folder2 prefix3 '.tsv'],'');
writematrix(ts_out,filename2save3,'filetype','text','delimiter','\t');



%% Incorporate somewhere or make into a separate script for quick check?
%count censoring -- we should do this through the censor_ups_mancor instead!!!
% outlier_indices = find(ts_adjust > (2*stdlev) | ts_adjust < (-2*stdlev)); %Find the indices of values outside the bounds
% num_outliers = length(outlier_indices);    %Count the number of outliers
% perc_outliers = num_outliers / length(ts_clean);
%^ atm, not sure if this is only considering times during scan or the whole
%length of the phys trace... Check... 



