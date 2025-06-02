% Trying to deconvolve the phys signals and plot subject-level and
% group-level, thresholded response functions

%% Define Inputs and directories
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))
phys_type = 'MAP';          %MAP, lfo
taskOI='outhold';           %resting, inhold, outhold
delay_range = '-9sto18s';   %-9sto18s or 0sto21s
conv_type = '';      %'_sinwaves' or '', which would indicate the use of an identity matrix
delay_range_type = [delay_range, conv_type];
dir1 = '/data/SFIM_physio/physio/physio_results';
dir_mask = '/data/SFIM_physio/atlases_rs';

lmin = -9;
lmax = 18;
dl = 0.75;
tarray = [lmin:dl:lmax];
num_TR=4;
delay_range = strjoin([lmin "sto" lmax "s_dl" num_TR "TR"],'');

%% Define subject list
% subjects = ["18"];
if strncmp(taskOI,'resting',4)
    %resting: skip 17,28,29,33
    subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","26","27","30","31","32","34"];
elseif strncmp(taskOI,'inhold',4)
    %inhold: skip 10,17,26,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","27","28","30","31","32","33","34"];
elseif strncmp(taskOI,'outhold',4)
    %outhold: skip 10,17,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
end

%% Run loop
RF_mat = [];
RF_mat_norm = [];
RF_mat_thres = [];
RF_mat_thres_norm = [];
RF_mat_parcel = [];
RF_mat_parcel_norm = [];

for ii = 1:length(subjects)
    
    sbjid = subjects(ii);
    
    %% Load files
    % Load MAP
    map_file = strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR_',taskOI,'.tsv'],'');
    map_data = readtable(map_file, "FileType", "text", 'Delimiter', '\t');
    map_ts = table2array(map_data(:,2));
    map_time = table2array(map_data(:,1));
    
    % Load LFO
    lfo_file = strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_lfo_downsampled2TR_',taskOI,'.tsv'],'');
    lfo_data = readtable(lfo_file, "FileType", "text", 'Delimiter', '\t');
    lfo_ts = table2array(lfo_data(:,2));
    lfo_time = table2array(lfo_data(:,1));
    
    % Load voxel timeseries from fMRI brain data
    dir2 = strjoin(['/data/SFIM_physio/data/derivatives/sub' sbjid '/Resp_Func'],'');
    sbjid_brain_file = strjoin([dir2 '/' sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_RespFunc_interp.nii'],'');
    sbjid_brain = load_nii(char(sbjid_brain_file));
    sbjid_brain_img = sbjid_brain.img;
    
    %% Let's only consider the fits for the response function
    dim = size(sbjid_brain_img); 
    sbjid_brain_img_rf = sbjid_brain_img(:,:,:,:);
    dimrf=size(sbjid_brain_img_rf);
    sbjid_brain_img_rf_rs=reshape(squeeze(sbjid_brain_img_rf), [dimrf(1),dimrf(2),dimrf(3),dimrf(4)]);
    dimrfrs=size(sbjid_brain_img_rf_rs);    %rf = fits only for response function, and rs = resized

    %% Apply Masks
    % Load GM mask
    gm_mask = load_nii([dir_mask '/aparc.a2009s+aseg_REN_gm_rs.nii']);
    gm_mask_img = gm_mask.img;
    gm_mask_img_norm = (double(gm_mask_img) - double(min(gm_mask_img(:)))) ./ double(max(gm_mask_img(:)));
    gm_mask_thr = gm_mask_img_norm;
    gm_mask_thr(gm_mask_thr>0)=1;
    gm_mask_thr(gm_mask_thr<=0)=NaN;

    % Load brain mask
    brain_mask = load_nii([dir_mask '/HarvardOxford-sub-maxprob-thr0-2mm_rs.nii']);
    brain_mask_img = brain_mask.img;
    brain_mask_thr = brain_mask_img;
    brain_mask_thr(brain_mask_thr>0)=1;
    brain_mask_thr(brain_mask_thr<=0)=NaN;

    % Apply brain and GM masks to group delay map
    slice_idx=50;
    sbjid_brain_img_gm = sbjid_brain_img_rf_rs .* double(gm_mask_thr);
    sbjid_brain_img_brain = sbjid_brain_img_rf_rs .* double(brain_mask_thr);
    sbjid_brain_img_gm_brain = sbjid_brain_img_gm .* double(brain_mask_thr);
    % figure(1); tiledlayout(2,1); nexttile; imagesc(sbjid_brain_img_gm(:,:,slice_idx)); colorbar; ylabel('GM masked');
    % nexttile; imagesc(sbjid_brain_img_gm_brain(:,:,slice_idx)); colorbar; ylabel('GM and brain masked');

    %% Let's try to average
    submat=reshape(squeeze(sbjid_brain_img_gm_brain), [dimrfrs(1)*dimrfrs(2)*dimrfrs(3), dimrfrs(4)]);
    sbj_gm_avg_ts = mean(submat,1,'omitnan');
    
    %% Threshold using Fstat map _stats Full_Fstat index...
    % Make a mask of all voxels with Fstat equal to or greater than F_thres
    % F_thres = 3.0;      % 3 is fairly conservative. Try 2.3, perahps?

    % Load Fstat maps
    fstat_map = load_nii(char(strjoin([dir2 '/' sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_stats.nii'],'')));
    fstat_map_img = fstat_map.img;
    fstat_map_img_full = fstat_map_img(:,:,:,2);      % Full fstat is the second index

    % Try plotting a histogram to show Fstat distribution
    % figure(4); histogram(fstat_map_img_full)

    % Threshold based on 95th percentile of fitted voxels
    perc_val = 95;
    F_thres = prctile(fstat_map_img_full, perc_val, "all");

    % Create a mask of Fstats that are above F_thres
    fstat_sets_avg_mask = fstat_map_img_full;
    fstat_sets_avg_mask(fstat_sets_avg_mask>=F_thres)=1000;
    fstat_sets_avg_mask(fstat_sets_avg_mask<F_thres)=NaN;
    fstat_sets_avg_mask(fstat_sets_avg_mask==1000)=1;
    % imagesc(fstat_sets_avg_mask(:,:,50))

    % Apply mask to subject brain
    sbjid_brain_img_gm_brain_thres = sbjid_brain_img_gm_brain .* double(fstat_sets_avg_mask);
    % imagesc(sbjid_brain_img_gm_brain_thres(:,:,50))

    % Create a new matrix
    dim_thres = size(fstat_sets_avg_mask);
    submat_thres=reshape(sbjid_brain_img_gm_brain_thres, [dim_thres(1)*dim_thres(2)*dim_thres(3) dimrfrs(4)]);

    % Average a-new
    sbj_gm_avg_ts_thres = mean(submat_thres,1,'omitnan');

    % Generate matrix of response function curves across subjects, thresholded
    RF_mat_thres = [RF_mat_thres; sbj_gm_avg_ts_thres];

    sbj_gm_avg_ts_thres_norm = sbj_gm_avg_ts_thres / (max(sbj_gm_avg_ts_thres) - min(sbj_gm_avg_ts_thres));
    RF_mat_thres_norm = [RF_mat_thres_norm; sbj_gm_avg_ts_thres_norm];
    
    %% Particular parcel of interest (https://github.com/ThomasYeoLab/CBIG/blob/master/stable_projects/brain_parcellation/Yan2023_homotopic/parcellations/MNI/yeo7/fsleyes_lut/100Parcels_Yeo2011_7Networks_LUT.txt)
    parcel_atlas_filename = '/data/SFIM_physio/scripts/burak/100ParcelsREG.nii';
    parcel_atlas = load_nii(parcel_atlas_filename);
    parcel_atlas_img = parcel_atlas.img;

    parcel_atlas_img(parcel_atlas_img==39)=1000;
    parcel_atlas_img = single(parcel_atlas_img);
    parcel_atlas_img(parcel_atlas_img<200)=NaN;
    parcel_atlas_img(parcel_atlas_img==1000)=1;
    % imagesc(parcel_atlas_img(:,:,60))

    % Apply parcellated mask to subject brain
    sbjid_brain_img_parcel = sbjid_brain_img .* double(parcel_atlas_img);
    % imagesc(sbjid_brain_img_parcel(:,:,60))

    % Create a new matrix
    submat_parcel=reshape(sbjid_brain_img_parcel, [dim_thres(1)*dim_thres(2)*dim_thres(3) dimrfrs(4)]);

    % Average a-new
    sbj_parcel_avg_ts = mean(submat_parcel,1,'omitnan');

    % Generate matrix of response function curves across subjects, parcellated
    RF_mat_parcel = [RF_mat_parcel; sbj_parcel_avg_ts];
    sbj_parcel_avg_ts_norm = sbj_parcel_avg_ts / (max(sbj_parcel_avg_ts) - min(sbj_parcel_avg_ts));
    RF_mat_parcel_norm = [RF_mat_parcel_norm; sbj_parcel_avg_ts_norm];

    if sine_conv == 1   % not using this condition anymore. 
        %You'll need to multiply those estimates by the 8 sign waves and 
        %then add them together to get your response function shape.

        %% Define sine waves (8 with different period counts)
        N = ((lmax-lmin)/dl)+1;
        
        %figure(2); tiledlayout(8,1);
        %nexttile; % 1: cos with 1 period over N volumes
        cos1 = cos((tarray-lmin)/(lmax-lmin)*2*pi); %plot(tarray,cos1);
        %nexttile; % 2: sin with 1 period over N volumes
        sin1 = sin((tarray-lmin)/(lmax-lmin)*2*pi); %plot(tarray,sin1);
        %nexttile; % 3: cos with 2 periods over N volumes
        cos2 = cos((tarray-lmin)/(lmax-lmin)*4*pi); %plot(tarray,cos2);
        %nexttile; % 4: sin with 2 periods over N volumes
        sin2 = sin((tarray-lmin)/(lmax-lmin)*4*pi); %plot(tarray,sin2);
        %nexttile; % 5: cos with 3 periods over N volumes
        cos3 = cos((tarray-lmin)/(lmax-lmin)*6*pi); %plot(tarray,cos3);
        %nexttile; % 6: sin with 3 periods over N volumes
        sin3 = sin((tarray-lmin)/(lmax-lmin)*6*pi); %plot(tarray,sin3);
        %nexttile; % 7: cos with 4 periods over N volumes
        cos4 = cos((tarray-lmin)/(lmax-lmin)*8*pi); %plot(tarray,cos4);
        %nexttile; % 8: sin with 4 periods over N volumes
        sin4 = sin((tarray-lmin)/(lmax-lmin)*8*pi); %plot(tarray,sin4);
    
        %% Generate 4D matrix of sine waves
        mat_ones = ones([dimrfrs(1), dimrfrs(2), dimrfrs(3), length(cos1)]);
        dim_ones = size(mat_ones);
        mat_ones_rs = reshape(mat_ones, [dim_ones(1)*dim_ones(2)*dim_ones(3), dim_ones(4)]);
    
        cos1_2d = mat_ones_rs .* cos1;
        cos1_4d = reshape(cos1_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        sin1_2d = mat_ones_rs .* sin1;
        sin1_4d = reshape(sin1_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        cos2_2d = mat_ones_rs .* cos2;
        cos2_4d = reshape(cos2_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        sin2_2d = mat_ones_rs .* sin2;
        sin2_4d = reshape(sin2_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        cos3_2d = mat_ones_rs .* cos3;
        cos3_4d = reshape(cos3_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        sin3_2d = mat_ones_rs .* sin3;
        sin3_4d = reshape(sin3_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        cos4_2d = mat_ones_rs .* cos4;
        cos4_4d = reshape(cos4_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);
        sin4_2d = mat_ones_rs .* sin4;
        sin4_4d = reshape(sin4_2d, [dim_ones(1), dim_ones(2), dim_ones(3), dim_ones(4)]);

        %% Now that I have a brain map with 8 beta values per voxel, I'll multiply each of those betas by all of the 8 sin waves.
        sbjid_brain_img_gm_brain_b1 = sbjid_brain_img_gm_brain(:,:,:,1) .* cos1_4d;
        sbjid_brain_img_gm_brain_b2 = sbjid_brain_img_gm_brain(:,:,:,2) .* sin1_4d;
        sbjid_brain_img_gm_brain_b3 = sbjid_brain_img_gm_brain(:,:,:,3) .* cos2_4d;
        sbjid_brain_img_gm_brain_b4 = sbjid_brain_img_gm_brain(:,:,:,4) .* sin2_4d;
        sbjid_brain_img_gm_brain_b5 = sbjid_brain_img_gm_brain(:,:,:,5) .* cos3_4d;
        sbjid_brain_img_gm_brain_b6 = sbjid_brain_img_gm_brain(:,:,:,6) .* sin3_4d;
        sbjid_brain_img_gm_brain_b7 = sbjid_brain_img_gm_brain(:,:,:,7) .* cos4_4d;
        sbjid_brain_img_gm_brain_b8 = sbjid_brain_img_gm_brain(:,:,:,8) .* sin4_4d;

        %% Across the 8 sets of arrays, add them together
        sbjid_brain_img_gm_brain_bsum = sbjid_brain_img_gm_brain_b1 + sbjid_brain_img_gm_brain_b2 + ...
            sbjid_brain_img_gm_brain_b3 + sbjid_brain_img_gm_brain_b4 + sbjid_brain_img_gm_brain_b5 + ...
            sbjid_brain_img_gm_brain_b6 + sbjid_brain_img_gm_brain_b7 + sbjid_brain_img_gm_brain_b8;

        %% Let's try to average
        submat=reshape(squeeze(sbjid_brain_img_gm_brain_bsum), [dim_ones(1)*dim_ones(2)*dim_ones(3), dim_ones(4)]);
        sbj_gm_avg_ts = mean(submat,1,'omitnan');

        %% Threshold using Fstat map _stats Full_Fstat index
        % Make a mask of all voxels with Fstat equal to or greater than F_thres
        F_thres = 3.0;      % 3 is fairly conservative. Try 2.3, perahps?
    
        % Load fstat mask
        dir4 = '/data/SFIM_physio/data/derivatives';
        fstat_mask = load_nii(char(strjoin([dir4 '/sub' sbjid '/Resp_Func/' sbjid '_' taskOI '_MAP_lagged_' delay_range_type '_stats.nii'],'')));
        fstat_mask_img = fstat_mask.img;
        dim_fstat = size(fstat_mask_img);
        fstat_mask_img_rs=reshape(squeeze(fstat_mask_img), [dim_fstat(1),dim_fstat(2),dim_fstat(3),dim_fstat(5)]);
        fstat_mask_img_rs_full = fstat_mask_img_rs(:,:,:,1);
        fstat_mask_img_rs_full_nan = fstat_mask_img_rs_full;
        fstat_mask_img_rs_full_nan(fstat_mask_img_rs_full>=3)=1000;
        fstat_mask_img_rs_full_nan(fstat_mask_img_rs_full_nan<3)=NaN;
        fstat_mask_img_rs_full_nan(fstat_mask_img_rs_full_nan==1000)=1;
        imagesc(fstat_mask_img_rs_full_nan(:,:,50))
    
        % Apply mask to subject brain
        sbjid_brain_img_gm_brain_thres = sbjid_brain_img_gm_brain_bsum .* double(fstat_mask_img_rs_full_nan);
        imagesc(sbjid_brain_img_gm_brain_thres(:,:,50))
    
        % Create a new matrix
        dim_thres = size(fstat_mask_img_rs_full_nan);
        submat_thres=reshape(sbjid_brain_img_gm_brain_thres, [dim_thres(1)*dim_thres(2)*dim_thres(3) dim_ones(4)]);
    
        % Average a-new
        sbj_gm_avg_ts_thres = mean(submat_thres,1,'omitnan');
    
        % Generate matrix of response function curves across subjects, thresholded
        RF_mat_thres = [RF_mat_thres; sbj_gm_avg_ts_thres];
    
        sbj_gm_avg_ts_thres_norm = sbj_gm_avg_ts_thres / (max(sbj_gm_avg_ts_thres) - min(sbj_gm_avg_ts_thres));
        RF_mat_thres_norm = [RF_mat_thres_norm; sbj_gm_avg_ts_thres_norm];

    end

    %% Generate matrix of response function curves across subjects
    RF_mat = [RF_mat; sbj_gm_avg_ts];

    sbj_gm_avg_ts_norm = sbj_gm_avg_ts / (max(sbj_gm_avg_ts) - min(sbj_gm_avg_ts));
    RF_mat_norm = [RF_mat_norm; sbj_gm_avg_ts_norm];

    %% Save the GM averaged response function
    disp('have yet to save it!')
    
end

%% Plot non-thresholded
RF_avg = mean(RF_mat, 1);

figure(1); 
plot(tarray, RF_mat); title(['MAP RF averaged across all GM voxels ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_avg, 'LineWidth', 2)

figure(2); 
plot(tarray, RF_mat_norm); title(['NORMALIZED MAP RF averaged across all GM voxels ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_avg, 'LineWidth', 2)

%% Plot thresholded
RF_thres_avg = mean(RF_mat_thres, 1);

figure(3); 
plot(tarray, RF_mat_thres); title(['Thresholded MAP RF averaged across all GM voxels ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_thres_avg, 'LineWidth', 2)

figure(4); 
plot(tarray, RF_mat_thres_norm); title(['Thresholded NORMALIZED MAP RF averaged across all GM voxels ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_thres_avg, 'LineWidth', 2)

%% Plot Parcelated
RF_parcel_avg = mean(RF_mat_parcel, 1);

figure(5); 
plot(tarray, RF_mat_parcel); title(['Parcelated MAP RF averaged ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_parcel_avg, 'LineWidth', 2)

figure(6); 
plot(tarray, RF_mat_parcel_norm); title(['Parcelated NORMALIZED MAP RF averaged ', taskOI, ' ', delay_range_type])
xlabel('Time (sec)'); ylabel('betas');
hold on; 
plot(tarray, RF_parcel_avg, 'LineWidth', 2)

%% Group-level stuff
% Note to self, I talked with Dan, and he said that it doesn't matter unless 
% if I want to do stuff that I (at the moment anyways) don't want to do. 
% For generating group-level response function, I could either
% a) Normalize the MAP regressor and brain data, then generate subject-specific 
% transfer functions and average
% b) Or, don't normalize MAP and brain data, and when generating the group-level 
% transfer function, normalize the subject-specific transfer function beforehand

% Check if there was a problem with colinearity with the new lags!

