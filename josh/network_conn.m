% Plots the phys regressors as well as the GM average timeseries in BOLD
% data, after computing this average. Also plots a cross correlation matrix
% of network connectivity. To make this a more useful plot though, consider
% doing across parcels instead of across entire networks (7 in total)

sbjid='18';
num_MR_volumes = 1200;                          %TRs (Column B) from https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit#gid=591357156
MRI_scan_length = 900;                          %seconds (Column F) from https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit#gid=591357156

dir1 = '/data/SFIM_physio/physio_old/';
dir2 = '/data/SFIM_physio/physio_new/physio_results/';
dir3 = '/data/SFIM_physio';
addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf
%addpath(genpath('/Users/deanjn/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/Tools for NIfTI and ANALYZE image')) %On Desktop

%get_labeled_tc does something similar from Burak: addpath(genpath('/data/SFIM/akin/bin/burak'));

%% Load masks
network_mask = load_nii([dir3 '/scripts/burak/7NETREG.nii']);
network_mask_img = network_mask.img;
network_mask_img_nan = network_mask_img;
imagesc(network_mask_img(:,:,50)); colorbar;

% Preallocate each of the 7 networks
network1_mask_img_nan=network_mask_img_nan;
network2_mask_img_nan=network_mask_img_nan;
network3_mask_img_nan=network_mask_img_nan;
network4_mask_img_nan=network_mask_img_nan;
network5_mask_img_nan=network_mask_img_nan;
network6_mask_img_nan=network_mask_img_nan;
network7_mask_img_nan=network_mask_img_nan;

% Let's define each of the networks from the NIFTI file
network1_mask_img_nan(network1_mask_img_nan==1)=1000;
network1_mask_img_nan(network1_mask_img_nan<10)=NaN;
network1_mask_img_nan(network1_mask_img_nan==1000)=1;
imagesc(network1_mask_img_nan(:,:,50)); colorbar; title('network1')

network2_mask_img_nan(network2_mask_img_nan==2)=1000;
network2_mask_img_nan(network2_mask_img_nan<10)=NaN;
network2_mask_img_nan(network2_mask_img_nan==1000)=1;
imagesc(network2_mask_img_nan(:,:,70)); colorbar; title('network2')

network3_mask_img_nan(network3_mask_img_nan==3)=1000;
network3_mask_img_nan(network3_mask_img_nan<10)=NaN;
network3_mask_img_nan(network3_mask_img_nan==1000)=1;
imagesc(network3_mask_img_nan(:,:,30)); colorbar; title('network3')

network4_mask_img_nan(network4_mask_img_nan==4)=1000;
network4_mask_img_nan(network4_mask_img_nan<10)=NaN;
network4_mask_img_nan(network4_mask_img_nan==1000)=1;
imagesc(network4_mask_img_nan(:,:,50)); colorbar; title('network4')

network5_mask_img_nan(network5_mask_img_nan==5)=1000;
network5_mask_img_nan(network5_mask_img_nan<10)=NaN;
network5_mask_img_nan(network5_mask_img_nan==1000)=1;
imagesc(network5_mask_img_nan(:,:,50)); colorbar; title('network5')

network6_mask_img_nan(network6_mask_img_nan==6)=1000;
network6_mask_img_nan(network6_mask_img_nan<10)=NaN;
network6_mask_img_nan(network6_mask_img_nan==1000)=1;
imagesc(network6_mask_img_nan(:,:,50)); colorbar; title('network6')

network7_mask_img_nan(network7_mask_img_nan==7)=1000;
network7_mask_img_nan(network7_mask_img_nan<10)=NaN;
network7_mask_img_nan(network7_mask_img_nan==1000)=1;
imagesc(network7_mask_img_nan(:,:,50)); colorbar; title('network7')

% Load subject brain data
%sbjid_brain = load_nii([dir3 '/data/bp' sbjid '/func_rest/pb04.bp' sbjid '.r01.scale.nii']);   %regular
%sbjid_brain = load_nii([dir3 '/data/derivatives/sub' sbjid '/func_rest_map_out/output.GLM_REML/sub' sbjid '_map_out_errts_REML.nii']);    %map regressed out
sbjid_brain = load_nii([dir3 '/data/derivatives/sub' sbjid '/func_rest_lfo_out/output.GLM_REML/sub' sbjid '_lfo_out_errts_REML.nii']);    %LFO regressed out
sbjid_brain_img = sbjid_brain.img;

%% Apply masks
sbjid_brain_img_net1 = sbjid_brain_img .* double(network1_mask_img_nan);
sbjid_brain_img_net2 = sbjid_brain_img .* double(network2_mask_img_nan);
sbjid_brain_img_net3 = sbjid_brain_img .* double(network3_mask_img_nan);
sbjid_brain_img_net4 = sbjid_brain_img .* double(network4_mask_img_nan);
sbjid_brain_img_net5 = sbjid_brain_img .* double(network5_mask_img_nan);
sbjid_brain_img_net6 = sbjid_brain_img .* double(network6_mask_img_nan);
sbjid_brain_img_net7 = sbjid_brain_img .* double(network7_mask_img_nan);

%% Let's check if these plots look reasonable
imagesc(sbjid_brain_img_net7(:,:,50,10)); colorbar; title('Are there values only within a network?')
histogram(sbjid_brain_img_net7(:,:,50,10)); title('Are there non-zero values?')

%% Now, let's try to average
dim=size(sbjid_brain_img_net1);
submat_net1=reshape(sbjid_brain_img_net1, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net1_avg_ts = mean(submat_net1,1,'omitnan');
sbj_net1_avg_ts_dm = sbj_net1_avg_ts - mean(sbj_net1_avg_ts);

dim=size(sbjid_brain_img_net2);
submat_net2=reshape(sbjid_brain_img_net2, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net2_avg_ts = mean(submat_net2,1,'omitnan');
sbj_net2_avg_ts_dm = sbj_net2_avg_ts - mean(sbj_net2_avg_ts);

dim=size(sbjid_brain_img_net3);
submat_net3=reshape(sbjid_brain_img_net3, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net3_avg_ts = mean(submat_net3,1,'omitnan');
sbj_net3_avg_ts_dm = sbj_net3_avg_ts - mean(sbj_net3_avg_ts);

dim=size(sbjid_brain_img_net4);
submat_net4=reshape(sbjid_brain_img_net4, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net4_avg_ts = mean(submat_net4,1,'omitnan');
sbj_net4_avg_ts_dm = sbj_net4_avg_ts - mean(sbj_net4_avg_ts);

dim=size(sbjid_brain_img_net5);
submat_net5=reshape(sbjid_brain_img_net5, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net5_avg_ts = mean(submat_net5,1,'omitnan');
sbj_net5_avg_ts_dm = sbj_net5_avg_ts - mean(sbj_net5_avg_ts);

dim=size(sbjid_brain_img_net6);
submat_net6=reshape(sbjid_brain_img_net6, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net6_avg_ts = mean(submat_net6,1,'omitnan');
sbj_net6_avg_ts_dm = sbj_net6_avg_ts - mean(sbj_net6_avg_ts);

dim=size(sbjid_brain_img_net7);
submat_net7=reshape(sbjid_brain_img_net7, [dim(1)*dim(2)*dim(3) dim(4)]);
sbj_net7_avg_ts = mean(submat_net7,1,'omitnan');
sbj_net7_avg_ts_dm = sbj_net7_avg_ts - mean(sbj_net7_avg_ts);

%% Cross correlation matrix
network_tss = [sbj_net1_avg_ts_dm; sbj_net2_avg_ts_dm; sbj_net3_avg_ts_dm; sbj_net4_avg_ts_dm; sbj_net5_avg_ts_dm; sbj_net6_avg_ts_dm; sbj_net7_avg_ts_dm];
network_tss = network_tss';
corr_mat = corr(network_tss);

figure(1)

% Replace upper triangle with NaNs
isupper = logical(triu(ones(size(corr_mat)),1));
corr_mat(isupper) = NaN;

h = heatmap(corr_mat,'MissingDataColor','w');
labels = ["1","2","3","4","5","6","7"];
h.XDisplayLabels = labels;
h.YDisplayLabels = labels; 
title(['sub' sbjid])


