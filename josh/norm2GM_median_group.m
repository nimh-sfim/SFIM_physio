% This script normalizes the group-level delays to the GM median
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf

%% Define the folder path based on phys_type
phys_type= 'MAP';   %lfo, MAP
taskOI = 'outhold'; %resting, inhold, outhold
delay_range='1030';   %10, 20

%% Load group NIFTIs -- decided to use the non-masked NIFTIs
dir1='/data/SFIM_physio/data/derivatives/group_rapidtide3.0/';
cd(dir1)
if phys_type == 'MAP'
    group_delay_nii = load_untouch_nii(['MAP_time_' taskOI '_' delay_range '_group.nii']);
    group_corr_nii = load_untouch_nii(['MAP_corr_' taskOI '_' delay_range '_group.nii']);
elseif phys_type == 'lfo'
    group_delay_nii = load_untouch_nii(['LFO_time_' taskOI '_' delay_range '_group.nii']);
    group_corr_nii = load_untouch_nii(['LFO_corr_' taskOI '_' delay_range '_group.nii']);
end

group_delay_nii_img=group_delay_nii.img;
group_corr_nii_img = group_corr_nii.img;

slice_idx=50;
h=struct;
h.f=zeros(1,6);%will contain the handles to the figures
h.f(1)=figure(1); tiledlayout(2,1); nexttile;
imagesc(group_delay_nii_img(:,:,slice_idx)); ylabel('Group Delay Slice'); colorbar; 
title('Delay and Corr Group Maps'); nexttile;
imagesc(group_corr_nii_img(:,:,slice_idx)); ylabel('Group Corr Slice'); colorbar;
% Do something about the speckles??!?

%% Calculate GM median
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

% Plot the masks
h.f(2)=figure(2); tiledlayout(3,1); nexttile; imagesc(cortical_mask_img(:,:,50)); ylabel('All parcels'); colorbar;
title('Harvard Oxford atlas used to define GM mask')
nexttile; imagesc(cortical_mask_img_nan(:,:,50)); ylabel('GM parcels only'); colorbar;
nexttile; imagesc(brain_mask_img_nan(:,:,slice_idx)); ylabel('brain mask')

% Apply brain and GM masks to group delay map
group_delay_gm = group_delay_nii_img .* double(cortical_mask_img_nan);  %cortical GM mask
group_delay_gm_brain = group_delay_gm .* double(brain_mask_img_nan);    %brain mask 
h.f(3)=figure(3); tiledlayout(2,1); nexttile; imagesc(group_delay_gm(:,:,slice_idx)); colorbar; ylabel('GM masked'); title('Group Delay')
nexttile; imagesc(group_delay_gm_brain(:,:,slice_idx)); colorbar; ylabel('GM and brain masked');

% Apply brain and GM masks to group corr map
group_corr_gm = group_corr_nii_img .* double(cortical_mask_img_nan);    %cortical GM mask
group_corr_gm_brain = group_corr_gm .* double(brain_mask_img_nan);      %brain mask 
h.f(4)=figure(4); tiledlayout(2,1); nexttile; imagesc(group_corr_gm(:,:,slice_idx)); colorbar; ylabel('GM masked'); title('Group Corr')
nexttile; imagesc(group_corr_gm_brain(:,:,slice_idx)); colorbar; ylabel('GM and brain masked');

%% Calculate median of those voxels
median_delay_gm = median(group_delay_gm_brain,"all",'omitnan');
median_corr_gm = median(group_corr_gm_brain,"all",'omitnan');

%% Subtract all voxels by GM median delay
group_delay_gm_brain_dm = group_delay_gm_brain - median_delay_gm;
group_corr_gm_brain_dm = group_corr_gm_brain - median_corr_gm;

%% Quick plot to visualize difference
% Let's check if these plots look reasonable before and after de-medianing
h.f(5)=figure(5);
t1 = tiledlayout(4,1); nexttile;
imagesc(group_delay_gm_brain(:,:,slice_idx)); colorbar; ylabel('Before'); nexttile;
histogram(group_delay_gm_brain(:,:,slice_idx)); ylabel('Before'); nexttile;
imagesc(group_delay_gm_brain_dm(:,:,slice_idx)); colorbar; ylabel('After'); nexttile;
histogram(group_delay_gm_brain_dm(:,:,slice_idx)); ylabel('After')
title(t1, 'Delay Group Map: Before & After subtracting median')

h.f(6)=figure(6);
t2 = tiledlayout(4,1); nexttile;
imagesc(group_corr_gm_brain(:,:,slice_idx)); colorbar; ylabel('Before'); nexttile;
histogram(group_corr_gm_brain(:,:,slice_idx)); ylabel('Before'); nexttile;
imagesc(group_corr_gm_brain_dm(:,:,slice_idx)); colorbar; ylabel('After'); nexttile;
histogram(group_corr_gm_brain_dm(:,:,slice_idx)); ylabel('After')
title(t2, 'Corr Group Map: Before & After subtracting median')
% It probably means nothing to normalize correlations... But hey might as
% well do it while I'm doing the delay in case i'm being silly rn

%% Subtract across *all* voxels, not just saving the GM voxel output???
% Apply brain mask
group_delay_brain = group_delay_nii_img .* double(brain_mask_img_nan);
group_corr_brain = group_corr_nii_img .* double(brain_mask_img_nan);

% Subtract brain masked matrix by the median GM value
group_delay_brain_dm = group_delay_brain - median_delay_gm;
group_corr_brain_dm = group_corr_brain - median_corr_gm;

%% Save NIFTIs
% Initialize to be in correct NIFTI format structure
group_tmp1 = group_delay_nii; group_tmp2 = group_delay_nii; group_tmp3 = group_delay_nii; 
group_tmp4 = group_delay_nii; group_tmp5 = group_delay_nii; group_tmp6 = group_delay_nii;

if phys_type == 'MAP'
    group_delay_gm_brain_nii = make_nii(group_delay_gm_brain);
    group_tmp1.img = group_delay_gm_brain_nii.img;
    save_untouch_nii(group_tmp1,['MAP_time_' taskOI '_' delay_range '_group_GM.nii'])

    group_corr_gm_brain_nii = make_nii(group_corr_gm_brain);
    group_tmp2.img = group_corr_gm_brain_nii.img;
    save_untouch_nii(group_tmp2,['MAP_corr_' taskOI '_' delay_range '_group_GM.nii'])

    group_delay_gm_brain_dm_nii = make_nii(group_delay_gm_brain_dm);
    group_tmp3.img = group_delay_gm_brain_dm_nii.img;
    save_untouch_nii(group_tmp3,['MAP_time_' taskOI '_' delay_range '_group_GM_dm.nii'])
    
    group_corr_gm_brain_dm_nii = make_nii(group_corr_gm_brain_dm);
    group_tmp4.img = group_corr_gm_brain_dm_nii.img;
    save_untouch_nii(group_tmp4,['MAP_corr_' taskOI '_' delay_range '_group_GM_dm.nii'])
    
    group_delay_brain_dm_nii = make_nii(group_delay_brain_dm);
    group_tmp5.img = group_delay_brain_dm_nii.img;
    save_untouch_nii(group_tmp5,['MAP_time_' taskOI '_' delay_range '_group_brain_dm.nii'])
    
    group_corr_brain_dm_nii = make_nii(group_corr_brain_dm);
    group_tmp6.img = group_corr_brain_dm_nii.img;
    save_untouch_nii(group_tmp6,['MAP_corr_' taskOI '_' delay_range '_group_brain_dm.nii'])
elseif phys_type == 'lfo'
    group_delay_gm_brain_nii = make_nii(group_delay_gm_brain);
    group_tmp1.img = group_delay_gm_brain_nii.img;
    save_untouch_nii(group_tmp1,['LFO_time_' taskOI '_' delay_range '_group_GM.nii'])

    group_corr_gm_brain_nii = make_nii(group_corr_gm_brain);
    group_tmp2.img = group_corr_gm_brain_nii.img;
    save_untouch_nii(group_tmp2,['LFO_corr_' taskOI '_' delay_range '_group_GM.nii'])
    
    group_delay_gm_brain_dm_nii = make_nii(group_delay_gm_brain_dm);
    group_tmp3.img = group_delay_gm_brain_dm_nii.img;
    save_untouch_nii(group_tmp3,['LFO_time_' taskOI '_' delay_range '_group_GM_dm.nii'])
    
    group_corr_gm_brain_dm_nii = make_nii(group_corr_gm_brain_dm);
    group_tmp4.img = group_corr_gm_brain_dm_nii.img;
    save_untouch_nii(group_tmp4,['LFO_corr_' taskOI '_' delay_range '_group_GM_dm.nii'])
    
    group_delay_brain_dm_nii = make_nii(group_delay_brain_dm);
    group_tmp5.img = group_delay_brain_dm_nii.img;
    save_untouch_nii(group_tmp5,['LFO_time_' taskOI '_' delay_range '_group_brain_dm.nii'])
    
    group_corr_brain_dm_nii = make_nii(group_corr_brain_dm);
    group_tmp6.img = group_corr_brain_dm_nii.img;
    save_untouch_nii(group_tmp6,['LFO_corr_' taskOI '_' delay_range '_group_brain_dm.nii'])
end

for n=numel(h.f):-1:1   %show figures in reverse order, starting with figure(1)
    figure(h.f(n))
end

% The GM masked and brain masked appear slightly misaligned??? Check this

