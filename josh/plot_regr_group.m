% Plot group averaged phys traces based on inhold or outhold task design

%% Define inputs and plotting parameters
clc;clear;
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh

dir1 = '/data/SFIM_physio/physio/physio_results';
%addpath(genpath('/Users/deanjn/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/Tools for NIfTI and ANALYZE image'))
addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf
addpath(genpath('/data/SFIM_physio/dependencies/Scattered Data Interpolation and Approximation using Radial Base Functions/'))

%% Task parameters, as defined by Respiration_Task_Version_5_0.py found in /task folder
% All of these are in seconds!!! Will convert to TR at the end... 

% Inhold task design
inspiration_duration_inhold = 5;        % Inspiration duration (seconds)
expiration_duration_inhold = 3;         % Expiration duration (seconds)
hold_time_inhold = 15;                  % Hold time (seconds)
free_breathe_inhold = 30;               % Free breathe period (seconds)
block_number_inhold = 6;                % Number of blocks
cycle_number_inhold = 10;               % Number of cycles (per block)

cycle_times_inhold = [0,2];
inhale_times_inhold = [2,7];
bh_times_inhold = [7,22];
exhale_times_inhold = [22,25];
pb_times_inhold = [25,55];

cycle4inhold = [cycle_times_inhold;inhale_times_inhold;bh_times_inhold;...
    exhale_times_inhold;pb_times_inhold];

cycle4inhold = cycle4inhold / 0.75;

% Outhold task design
inspiration_duration_outhold = 5;   % Inspiration duration (seconds)
expiration_duration_outhold = 3;    % Expiration duration (seconds)
hold_time_outhold = 15;             % Hold time (seconds)
free_breathe_outhold = 30;          % Free breathe period (seconds)
block_number_outhold = 6;           % Number of blocks
cycle_number_outhold = 10;          % Number of cycles (per block)

cycle_times_outhold = [0,2];
inhale_times_outhold = [2,7];
exhale_times_outhold = [7,10];
bh_times_outhold = [10,25];
pb_times_outhold = [25,55];

cycle4outhold = [cycle_times_outhold;inhale_times_outhold;exhale_times_outhold;...
    bh_times_outhold;pb_times_outhold];

cycle4outhold = cycle4outhold / 0.75;

cycle_dur = 55 / 0.75;

%% Start loop to plot across subjects

lfo_ts_norm_mat = [];

%what about 17 and 29?
%have momentarily skipped sub25. Removed atm but return back to. 
subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","26","27","28","30","31","32","33","34"];

%% Saving LFO matrix

%for ii = 1:length(subjects)
ii = 1;     % initialize

while ii <= length(subjects)
    
    is_data_synchronizable = true;  %by default, set to true to run the processing
    
    while is_data_synchronizable    %some subjects are not able to be synchronized
    
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
    
        %% Load phys data and define plotting properties
        lfo_file = strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_lfo_downsampled2TR_',taskOI,'.tsv'],'');
        lfo_data = readtable(lfo_file, "FileType", "text", 'Delimiter', '\t');
        
        lfo_ts = table2array(lfo_data(:,2));
        lfo_time = table2array(lfo_data(:,1));
    
        %% Normalize the regressor to have ranges between 0 and 1
        lfo_ts_norm = (lfo_ts - min(lfo_ts)) / (max(lfo_ts) - min(lfo_ts));
        lfo_ts_norm = lfo_ts_norm';
    
        lfo_ts_norm_mat = [lfo_ts_norm_mat; {lfo_ts_norm}];

        is_data_synchronizable = true;  %by default, set to true to run the processing
        
        if ii == length(subjects)
            ii = ii+1;  % otherwise will re-do the subject
            break       % indicates that we've reached the end of the subject list
        end
        
        ii = ii+1;      %increase while in for loop. Otherwise will continue to do the same subject.

    end

end


%% Saving MAP matrix

map_ts_norm_mat = [];

%for jj = 1:length(subjects)
ii = 1;     % initialize

while ii <= length(subjects)
    
    is_data_synchronizable = true;  %by default, set to true to run the processing
    
    while is_data_synchronizable    %some subjects are not able to be synchronized
    
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
        elseif sbjid == "33" && strncmp(taskOI,'rest',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "33" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "31" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "33" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Cannot synchronize'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break
        end

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
    
        %% Load phys data and define plotting properties
        map_file = strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR_',taskOI,'.tsv'],'');
        map_data = readtable(map_file, "FileType", "text", 'Delimiter', '\t');
        
        map_ts = table2array(map_data(:,2));
        map_time = table2array(map_data(:,1));
    
        %% Normalize the regressor to have ranges between 0 and 1
        map_ts_norm = (map_ts - min(map_ts)) / (max(map_ts) - min(map_ts));
        map_ts_norm = map_ts_norm';
    
        map_ts_norm_mat = [map_ts_norm_mat; {map_ts_norm}];     %{} because different sizes

        is_data_synchronizable = true;  %by default, set to true to run the processing
        
        if ii == length(subjects)
            ii = ii+1;  % otherwise will re-do the subject
            break       % indicates that we've reached the end of the subject list
        end
        
        ii = ii+1;      %increase while in for loop. Otherwise will continue to do the same subject.

    end
end


%% Saving GM matrix
% Now, let's look at relationship between GM too... 
% Load GM mask
dir3 = '/data/SFIM_physio';
cortical_mask = load_nii([dir3 '/atlases_rs/HarvardOxford-sub-maxprob-thr0-2mm_rs.nii']);
cortical_mask_img = cortical_mask.img;
cortical_mask_img_nan = cortical_mask_img;
cortical_mask_img_nan(cortical_mask_img==2)=1000;
cortical_mask_img_nan(cortical_mask_img==13)=1000;
cortical_mask_img_nan(cortical_mask_img_nan<21)=NaN;
cortical_mask_img_nan(cortical_mask_img_nan==1000)=1;

% Load brain mask, as the GM mask extends past the brain. The GM mask probably isn't the optimal choice... 
brain_mask = load_nii([dir3 '/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii']);
brain_mask_img = brain_mask.img;
brain_mask_img_nan = single(brain_mask_img);    %single is important to allow for voxel to have a value of NaN
brain_mask_img_nan(brain_mask_img==0)=NaN;

% Plot the mask
% slice_idx = 50;
% tiledlayout(3,1); nexttile; imagesc(cortical_mask_img(:,:,50)); ylabel('All parcels'); colorbar;
% title('Harvard Oxford atlas used to define GM mask')
% nexttile; imagesc(cortical_mask_img_nan(:,:,50)); ylabel('GM parcels only'); colorbar;
% nexttile; imagesc(brain_mask_img_nan(:,:,slice_idx)); ylabel('brain mask')

GM_norm_mat = [];
for ii = 1:length(subjects)
    sbjid = subjects(ii);

    % Load subject brain data
    sbjid_brain_file = strjoin([dir3 '/data/bp' sbjid '/func_' task4let '/pb04.bp' sbjid '.r01.scale.nii'],'');
    sbjid_brain = load_nii(char(sbjid_brain_file));
    sbjid_brain_img = sbjid_brain.img;

    % Apply masks
    sbjid_brain_img_gm = sbjid_brain_img .* double(cortical_mask_img_nan);          %cortical GM mask
    sbjid_brain_img_gm_brain = sbjid_brain_img_gm .* double(brain_mask_img_nan);    %brain mask 

    % Let's check if these plots look reasonable
    % imagesc(sbjid_brain_img_gm_brain(:,:,50,10)); colorbar; title('Are there values only within GM voxels?')
    % histogram(sbjid_brain_img_gm_brain(:,:,50,10)); title('Are there non-zero values?')

    % Now, let's try to average
    dim=size(sbjid_brain_img_gm_brain);
    submat=reshape(sbjid_brain_img_gm_brain, [dim(1)*dim(2)*dim(3) dim(4)]);
    sbj_gm_avg_ts = mean(submat,1,'omitnan');
    %sbj_gm_avg_ts_dm = sbj_gm_avg_ts - mean(sbj_gm_avg_ts);

    % Normalize the regressor to have ranges between 0 and 1
    GM_norm = (sbj_gm_avg_ts - min(sbj_gm_avg_ts)) / (max(sbj_gm_avg_ts) - min(sbj_gm_avg_ts));
    
    % Collapse into matrix of average GM timeseries data
    GM_norm_mat = [GM_norm_mat; {GM_norm}];     %{} because different sizes
end


%% Generate group averaged timeseries (LFO, MAP, GM)
% Pad with NaN's
% lfo and MAP phys data should have the same lengths
% GM voxel ts should have same lengths as lfo and MAP phys data
length_phys_mat = [];
for jj = 1:length(lfo_ts_norm_mat)
    length(lfo_ts_norm_mat{jj});
    length_phys_mat = [length_phys_mat; length(lfo_ts_norm_mat{jj})];
end
len2padto = max(length_phys_mat);

lfo_ts_norm_mat_sz = [];
for kk = 1:length(lfo_ts_norm_mat)
    new_array_tmp = [lfo_ts_norm_mat{kk}'; NaN(len2padto-length(lfo_ts_norm_mat{kk}),1)]';
    lfo_ts_norm_mat_sz = [lfo_ts_norm_mat_sz; new_array_tmp];  %same size rows in matrix, non-cell, format
end

map_ts_norm_mat_sz = [];
for kk = 1:length(map_ts_norm_mat)
    new_array_tmp = [map_ts_norm_mat{kk}'; NaN(len2padto-length(map_ts_norm_mat{kk}),1)]';
    map_ts_norm_mat_sz = [map_ts_norm_mat_sz; new_array_tmp];  %same size rows in matrix, non-cell, format
end

GM_norm_mat_sz = [];
for kk = 1:length(GM_norm_mat)
    new_array_tmp = [GM_norm_mat{kk}'; NaN(len2padto-length(GM_norm_mat{kk}),1)]';
    GM_norm_mat_sz = [GM_norm_mat_sz; new_array_tmp];  %same size rows in matrix, non-cell, format
end

lfo_avg = mean(lfo_ts_norm_mat_sz, 1, 'omitnan');

map_avg = mean(map_ts_norm_mat_sz, 1, 'omitnan');

GM_avg = mean(GM_norm_mat_sz, 1, 'omitnan');
GM_avg_detrend = detrend(GM_avg, 3);
GM_avg_detrend = detrend(GM_avg_detrend, 2);
GM_avg_detrend = detrend(GM_avg_detrend, 1);
%GM_avg_detrend = GM_avg_detrend-(median(GM_avg_detrend));
plot(GM_avg_detrend)

%% Try plotting outside the for loop
opacity_choice=255*0.4;
color_choice = [238, 238, 238, opacity_choice] / 255;   %light grey, participant chooses how to breath for 2 sec
color_in = [21, 127, 234, opacity_choice] / 255;        %blue, inspiration
color_bh = [234, 21, 127, opacity_choice] / 255;        %red, breath hold
color_exh = [127, 234, 21, opacity_choice] / 255;       %green, exhalation
color_fb = [221, 221, 221, opacity_choice] / 255;       %slightly darker grey, free breathing
line_width = 2;
font_size = 16;

%for rectangle colors, do gradation of corresponding CO2 increase?
%Or inhale is cool and exhale is warm? Also, change opacity.

%% Plot
figure(1)
if strncmp(taskOI,'inhold',4)
    for cycle = 0:cycle_number_inhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4inhold(1,1)+cycle_dur*cycle, 0, cycle4inhold(1,2)-cycle4inhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4inhold(2,1)+cycle_dur*cycle, 0, cycle4inhold(2,2)-cycle4inhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4inhold(3,1)+cycle_dur*cycle, 0, cycle4inhold(3,2)-cycle4inhold(3,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4inhold(4,1)+cycle_dur*cycle, 0, cycle4inhold(4,2)-cycle4inhold(4,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4inhold(5,1)+cycle_dur*cycle, 0, cycle4inhold(5,2)-cycle4inhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
elseif strncmp(taskOI,'outhold',4)
    for cycle = 0:cycle_number_outhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4outhold(1,1)+cycle_dur*cycle, 0, cycle4outhold(1,2)-cycle4outhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4outhold(2,1)+cycle_dur*cycle, 0, cycle4outhold(2,2)-cycle4outhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4outhold(3,1)+cycle_dur*cycle, 0, cycle4outhold(3,2)-cycle4outhold(3,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4outhold(4,1)+cycle_dur*cycle, 0, cycle4outhold(4,2)-cycle4outhold(4,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4outhold(5,1)+cycle_dur*cycle, 0, cycle4outhold(5,2)-cycle4outhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
end
hold on; plot(map_ts_norm_mat_sz', 'LineWidth', 0.5); 
hold on; plot(map_avg, 'LineWidth', line_width, 'Color', 'r');
title('MAP')

figure(2)
if strncmp(taskOI,'inhold',4)
    for cycle = 0:cycle_number_inhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4inhold(1,1)+cycle_dur*cycle, 0, cycle4inhold(1,2)-cycle4inhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4inhold(2,1)+cycle_dur*cycle, 0, cycle4inhold(2,2)-cycle4inhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4inhold(3,1)+cycle_dur*cycle, 0, cycle4inhold(3,2)-cycle4inhold(3,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4inhold(4,1)+cycle_dur*cycle, 0, cycle4inhold(4,2)-cycle4inhold(4,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4inhold(5,1)+cycle_dur*cycle, 0, cycle4inhold(5,2)-cycle4inhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
elseif strncmp(taskOI,'outhold',4)
    for cycle = 0:cycle_number_outhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4outhold(1,1)+cycle_dur*cycle, 0, cycle4outhold(1,2)-cycle4outhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4outhold(2,1)+cycle_dur*cycle, 0, cycle4outhold(2,2)-cycle4outhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4outhold(3,1)+cycle_dur*cycle, 0, cycle4outhold(3,2)-cycle4outhold(3,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4outhold(4,1)+cycle_dur*cycle, 0, cycle4outhold(4,2)-cycle4outhold(4,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4outhold(5,1)+cycle_dur*cycle, 0, cycle4outhold(5,2)-cycle4outhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
end
hold on; plot(lfo_ts_norm_mat_sz', 'LineWidth', 0.5); 
hold on; plot(lfo_avg, 'LineWidth', line_width);
title('LFO')

figure(3)
if strncmp(taskOI,'inhold',4)
    for cycle = 0:cycle_number_inhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4inhold(1,1)+cycle_dur*cycle, 0, cycle4inhold(1,2)-cycle4inhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4inhold(2,1)+cycle_dur*cycle, 0, cycle4inhold(2,2)-cycle4inhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4inhold(3,1)+cycle_dur*cycle, 0, cycle4inhold(3,2)-cycle4inhold(3,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4inhold(4,1)+cycle_dur*cycle, 0, cycle4inhold(4,2)-cycle4inhold(4,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4inhold(5,1)+cycle_dur*cycle, 0, cycle4inhold(5,2)-cycle4inhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
elseif strncmp(taskOI,'outhold',4)
    for cycle = 0:cycle_number_outhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4outhold(1,1)+cycle_dur*cycle, 0, cycle4outhold(1,2)-cycle4outhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4outhold(2,1)+cycle_dur*cycle, 0, cycle4outhold(2,2)-cycle4outhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4outhold(3,1)+cycle_dur*cycle, 0, cycle4outhold(3,2)-cycle4outhold(3,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4outhold(4,1)+cycle_dur*cycle, 0, cycle4outhold(4,2)-cycle4outhold(4,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4outhold(5,1)+cycle_dur*cycle, 0, cycle4outhold(5,2)-cycle4outhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
end
hold on; plot(GM_norm_mat_sz', 'LineWidth', 0.5); 
hold on; plot(GM_avg_detrend, 'LineWidth', line_width);
title('GM')

%% Let's do all the averages together. -- plots for different axes below
figure(4)
if strncmp(taskOI,'inhold',4)
    for cycle = 0:cycle_number_inhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4inhold(1,1)+cycle_dur*cycle, 0, cycle4inhold(1,2)-cycle4inhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4inhold(2,1)+cycle_dur*cycle, 0, cycle4inhold(2,2)-cycle4inhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4inhold(3,1)+cycle_dur*cycle, 0, cycle4inhold(3,2)-cycle4inhold(3,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4inhold(4,1)+cycle_dur*cycle, 0, cycle4inhold(4,2)-cycle4inhold(4,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4inhold(5,1)+cycle_dur*cycle, 0, cycle4inhold(5,2)-cycle4inhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
elseif strncmp(taskOI,'outhold',4)
    for cycle = 0:cycle_number_outhold-1
        % rectangle's position is [x y w h]
        rectangle('Position', [cycle4outhold(1,1)+cycle_dur*cycle, 0, cycle4outhold(1,2)-cycle4outhold(1,1), 1],'FaceColor',color_choice,'Curvature',0)
        rectangle('Position', [cycle4outhold(2,1)+cycle_dur*cycle, 0, cycle4outhold(2,2)-cycle4outhold(2,1), 1],'FaceColor',color_in,'Curvature',0)
        rectangle('Position', [cycle4outhold(3,1)+cycle_dur*cycle, 0, cycle4outhold(3,2)-cycle4outhold(3,1), 1],'FaceColor',color_exh,'Curvature',0)
        rectangle('Position', [cycle4outhold(4,1)+cycle_dur*cycle, 0, cycle4outhold(4,2)-cycle4outhold(4,1), 1],'FaceColor',color_bh,'Curvature',0)
        rectangle('Position', [cycle4outhold(5,1)+cycle_dur*cycle, 0, cycle4outhold(5,2)-cycle4outhold(5,1), 1],'FaceColor',color_fb,'Curvature',0)
    end
end
lfo_avg_01 = (lfo_avg - min(lfo_avg)) / (max(lfo_avg) - min(lfo_avg));
map_avg_01 = (map_avg - min(map_avg)) / (max(map_avg) - min(map_avg));
GM_avg_01 = (GM_avg_detrend - min(GM_avg_detrend)) / (max(GM_avg_detrend) - min(GM_avg_detrend));

hold on; plot(lfo_avg_01, 'LineWidth', line_width, 'DisplayName', 'LFO');
hold on; plot(map_avg_01, 'LineWidth', line_width, 'DisplayName', 'MAP');
hold on; plot(GM_avg_01, 'LineWidth', line_width, 'DisplayName', 'GM');
legend()

%% Now, let's look at the individual cycle averaged... 
%cycle4inhold
%cycle4outhold
%cycle_dur

% both tasks have same task lengths

% LFO, MAP, and GM are already in TR space. 
% 800 indices corresponds to 600 seconds.
% each cycle is 55 seconds, or 73.3333 TRs. 

cycle_start_idx = [];
for cycle = 0:cycle_number_outhold-1
    cycle_start_idx = [cycle_start_idx; cycle4outhold(1,1)+cycle_dur*cycle]
end
cycle_start_idx_ups = (cycle_start_idx * 3) + 1; %first index starts at 1, and ups by 3

% Let's upsample the average LFO, MAP, and GM timeseries data, because TRs
% are not indices that could use to divide up the timeseries accordingly.
% Upsampling by a factor of 3 resolves this. 
old_time = [0.75 : 0.75 : 600]; 
new_time = [0.75/3 : 0.75/3 : 600];     % new sampling grid, upsample by a factor of 3
smooth_factor = 0;
lfo_avg_01_tmp = rbfcreate(old_time,lfo_avg_01,'RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
lfo_avg_01_rs = rbfinterp(new_time, lfo_avg_01_tmp);
map_avg_01_tmp = rbfcreate(old_time,map_avg_01,'RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
map_avg_01_rs = rbfinterp(new_time, map_avg_01_tmp);
GM_avg_01_tmp = rbfcreate(old_time,GM_avg_01,'RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
GM_avg_01_rs = rbfinterp(new_time, GM_avg_01_tmp);

% plot(old_time, GM_avg_01); hold on; plot(new_time, GM_avg_01_rs);

lfo_avg_rs_each_cycle = [];
map_avg_rs_each_cycle = [];
GM_avg_rs_each_cycle = [];
for ii = 1:length(cycle_start_idx_ups)-1
    idx_cycle_ups = [cycle_start_idx_ups(ii), (cycle_start_idx_ups(ii+1) - 1)];
    lfo_avg_rs_each_cycle = [lfo_avg_rs_each_cycle; lfo_avg_01_rs([round(idx_cycle_ups(1)):round(idx_cycle_ups(2))])];
    map_avg_rs_each_cycle = [map_avg_rs_each_cycle; map_avg_01_rs([round(idx_cycle_ups(1)):round(idx_cycle_ups(2))])];
    GM_avg_rs_each_cycle = [GM_avg_rs_each_cycle; GM_avg_01_rs([round(idx_cycle_ups(1)):round(idx_cycle_ups(2))])];
end
% above doesn't include the last cycle? So let's do it now.
lfo_avg_rs_each_cycle = [lfo_avg_rs_each_cycle; lfo_avg_01_rs([cycle_start_idx_ups(10):cycle_start_idx_ups(10)+cycle_dur*3 - 1])];
map_avg_rs_each_cycle = [map_avg_rs_each_cycle; map_avg_01_rs([cycle_start_idx_ups(10):cycle_start_idx_ups(10)+cycle_dur*3 - 1])];
GM_avg_rs_each_cycle = [GM_avg_rs_each_cycle; GM_avg_01_rs([cycle_start_idx_ups(10):cycle_start_idx_ups(10)+cycle_dur*3 - 1])];

% Take the average across the cycles
lfo_cycle_avg = mean(lfo_avg_rs_each_cycle, 1);
map_cycle_avg = mean(map_avg_rs_each_cycle, 1);
GM_cycle_avg = mean(GM_avg_rs_each_cycle , 1);

%% Plots
figure(5)
if strncmp(taskOI,'inhold',4)
    rectangle('Position', [cycle4inhold(1,1), 0, (cycle4inhold(1,2)-cycle4inhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4inhold(2,1)*3, 0, (cycle4inhold(2,2)-cycle4inhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4inhold(3,1)*3, 0, (cycle4inhold(3,2)-cycle4inhold(3,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4inhold(4,1)*3, 0, (cycle4inhold(4,2)-cycle4inhold(4,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4inhold(5,1)*3, 0, (cycle4inhold(5,2)-cycle4inhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
elseif strncmp(taskOI,'outhold',4)
    rectangle('Position', [cycle4outhold(1,1), 0, (cycle4outhold(1,2)-cycle4outhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4outhold(2,1)*3, 0, (cycle4outhold(2,2)-cycle4outhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4outhold(3,1)*3, 0, (cycle4outhold(3,2)-cycle4outhold(3,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4outhold(4,1)*3, 0, (cycle4outhold(4,2)-cycle4outhold(4,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4outhold(5,1)*3, 0, (cycle4outhold(5,2)-cycle4outhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
end
hold on; plot(lfo_cycle_avg, 'LineWidth', line_width);
hold on; plot(lfo_avg_rs_each_cycle');
title('LFO Cycle Average'); xlabel('TR/3')

figure(6)
if strncmp(taskOI,'inhold',4)
    rectangle('Position', [cycle4inhold(1,1), 0, (cycle4inhold(1,2)-cycle4inhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4inhold(2,1)*3, 0, (cycle4inhold(2,2)-cycle4inhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4inhold(3,1)*3, 0, (cycle4inhold(3,2)-cycle4inhold(3,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4inhold(4,1)*3, 0, (cycle4inhold(4,2)-cycle4inhold(4,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4inhold(5,1)*3, 0, (cycle4inhold(5,2)-cycle4inhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
elseif strncmp(taskOI,'outhold',4)
    rectangle('Position', [cycle4outhold(1,1), 0, (cycle4outhold(1,2)-cycle4outhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4outhold(2,1)*3, 0, (cycle4outhold(2,2)-cycle4outhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4outhold(3,1)*3, 0, (cycle4outhold(3,2)-cycle4outhold(3,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4outhold(4,1)*3, 0, (cycle4outhold(4,2)-cycle4outhold(4,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4outhold(5,1)*3, 0, (cycle4outhold(5,2)-cycle4outhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
end
hold on; plot(map_avg_rs_each_cycle');
hold on; plot(map_cycle_avg, 'LineWidth', line_width);
title('MAP Cycle Average'); xlabel('TR/3')

figure(7)
if strncmp(taskOI,'inhold',4)
    rectangle('Position', [cycle4inhold(1,1), 0, (cycle4inhold(1,2)-cycle4inhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4inhold(2,1)*3, 0, (cycle4inhold(2,2)-cycle4inhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4inhold(3,1)*3, 0, (cycle4inhold(3,2)-cycle4inhold(3,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4inhold(4,1)*3, 0, (cycle4inhold(4,2)-cycle4inhold(4,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4inhold(5,1)*3, 0, (cycle4inhold(5,2)-cycle4inhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
elseif strncmp(taskOI,'outhold',4)
    rectangle('Position', [cycle4outhold(1,1), 0, (cycle4outhold(1,2)-cycle4outhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4outhold(2,1)*3, 0, (cycle4outhold(2,2)-cycle4outhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4outhold(3,1)*3, 0, (cycle4outhold(3,2)-cycle4outhold(3,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4outhold(4,1)*3, 0, (cycle4outhold(4,2)-cycle4outhold(4,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4outhold(5,1)*3, 0, (cycle4outhold(5,2)-cycle4outhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
end
hold on; plot(GM_avg_rs_each_cycle');
hold on; plot(GM_cycle_avg, 'LineWidth', line_width);
title('GM Cycle Average'); xlabel('TR/3')

figure(8)
if strncmp(taskOI,'inhold',4)
    rectangle('Position', [cycle4inhold(1,1), 0, (cycle4inhold(1,2)-cycle4inhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4inhold(2,1)*3, 0, (cycle4inhold(2,2)-cycle4inhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4inhold(3,1)*3, 0, (cycle4inhold(3,2)-cycle4inhold(3,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4inhold(4,1)*3, 0, (cycle4inhold(4,2)-cycle4inhold(4,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4inhold(5,1)*3, 0, (cycle4inhold(5,2)-cycle4inhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
elseif strncmp(taskOI,'outhold',4)
    rectangle('Position', [cycle4outhold(1,1), 0, (cycle4outhold(1,2)-cycle4outhold(1,1))*3, 1],'FaceColor',color_choice,'Curvature',0)
    rectangle('Position', [cycle4outhold(2,1)*3, 0, (cycle4outhold(2,2)-cycle4outhold(2,1))*3, 1],'FaceColor',color_in,'Curvature',0)
    rectangle('Position', [cycle4outhold(3,1)*3, 0, (cycle4outhold(3,2)-cycle4outhold(3,1))*3, 1],'FaceColor',color_exh,'Curvature',0)
    rectangle('Position', [cycle4outhold(4,1)*3, 0, (cycle4outhold(4,2)-cycle4outhold(4,1))*3, 1],'FaceColor',color_bh,'Curvature',0)
    rectangle('Position', [cycle4outhold(5,1)*3, 0, (cycle4outhold(5,2)-cycle4outhold(5,1))*3, 1],'FaceColor',color_fb,'Curvature',0)
end
hold on; plot(lfo_cycle_avg, 'LineWidth', line_width, 'DisplayName', 'LFO');
hold on; plot(map_cycle_avg, 'LineWidth', line_width, 'DisplayName', 'MAP');
hold on; plot(GM_cycle_avg, 'LineWidth', line_width, 'DisplayName', 'GM');
title('Cycle Averages'); xlabel('TR/3')
legend()


