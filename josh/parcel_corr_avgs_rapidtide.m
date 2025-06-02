% This scripts calculates the average correlation across parcels and networks for MAP and LFO
% Note: Dan had made a previous comment about dividing networks into parcels?

clc;clear;
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf

%% Define the folder path based on phys_type
taskOI = 'resting'; %resting, inhold, outhold
delay_range='10';   %10, 20

%% Load group NIFTIs -- decided to use the non-masked NIFTIs
dir1='/data/SFIM_physio/data/derivatives/group_test/';
cd(dir1)
map_group_delay_nii_fname = char(['MAP_time_' taskOI '_' delay_range '_group.nii']);
map_group_delay_nii = load_untouch_nii(map_group_delay_nii_fname);
map_group_corr_nii_fname = char(['MAP_corr_' taskOI '_' delay_range '_group.nii']);
map_group_corr_nii = load_untouch_nii(map_group_corr_nii_fname);
lfo_group_delay_nii_fname = char(['LFO_time_' taskOI '_' delay_range '_group.nii']);
lfo_group_delay_nii = load_untouch_nii(lfo_group_delay_nii_fname);
lfo_group_corr_nii_fname = char(['LFO_corr_' taskOI '_' delay_range '_group.nii']);
lfo_group_corr_nii = load_untouch_nii(lfo_group_corr_nii_fname);

map_group_delay_nii_img = map_group_delay_nii.img;
map_group_corr_nii_img = map_group_corr_nii.img;

lfo_group_delay_nii_img = lfo_group_delay_nii.img;
lfo_group_corr_nii_img = lfo_group_corr_nii.img;

%% Load 100 parcel map
atlpath='/data/SFIM_physio/scripts/YEO100.nii';
atlas = load_untouch_nii(char(atlpath));
atlas_img = atlas.img;

%%
map_corr_mat = [];
for ii = 1 : max(atlas_img(:))
    map_corr_parcel = map_group_corr_nii_img(atlas_img==ii);
    map_corr_mat = [map_corr_mat; {map_corr_parcel}];
end

lfo_corr_mat = [];
for ii = 1 : max(atlas_img(:))
    lfo_corr_parcel = lfo_group_corr_nii_img(atlas_img==ii);
    lfo_corr_mat = [lfo_corr_mat; {lfo_corr_parcel}];
end

%% Generate parcel averaged correlations
% Pad with NaN's
% There should be same lengths for both map and lfo, so just choosing map
length_mat = [];
for jj = 1:length(map_corr_mat)
    length(map_corr_mat{jj});
    length_mat = [length_mat; length(map_corr_mat{jj})];
end
len2padto = max(length_mat);

map_corr_mat_sz = [];
for kk = 1:length(map_corr_mat)
    map_new_array_tmp = [map_corr_mat{kk}; NaN(len2padto-length(map_corr_mat{kk}),1)]';
    map_corr_mat_sz = [map_corr_mat_sz; map_new_array_tmp];  %same size rows in matrix, non-cell, format
end
map_corr_avg = mean(map_corr_mat_sz', 1, 'omitnan');

lfo_corr_mat_sz = [];
for kk = 1:length(lfo_corr_mat)
    lfo_new_array_tmp = [lfo_corr_mat{kk}; NaN(len2padto-length(lfo_corr_mat{kk}),1)]';
    lfo_corr_mat_sz = [lfo_corr_mat_sz; lfo_new_array_tmp];  %same size rows in matrix, non-cell, format
end
lfo_corr_avg = mean(lfo_corr_mat_sz', 1, 'omitnan');



%% Plots
% Consider 1-50 and 51 to 100 are lateral to one another?
map_lateral_diff = map_corr_avg(1:50) - map_corr_avg(51:100);
lfo_lateral_diff = lfo_corr_avg(1:50) - lfo_corr_avg(51:100);
phys_diff = map_corr_avg(1:50) - lfo_corr_avg(1:50);

figure(1); tiledlayout(3,1)
nexttile; plot(map_corr_avg(1:50), '.'); ylabel('parcels 1:50')
title(['Average correlations across parcels for MAP with ' taskOI ' and ' delay_range 's delay range'])
nexttile; plot(map_corr_avg(51:100), '.'); ylabel('parcels 51:100')
nexttile; plot(map_lateral_diff, '.'); ylabel('symmetry test')

figure(2); tiledlayout(3,1)
nexttile; plot(lfo_corr_avg(1:50), '.'); ylabel('parcels 1:50')
title(['Average correlations across parcels for LFO with ' taskOI ' and ' delay_range 's delay range'])
nexttile; plot(lfo_corr_avg(51:100), '.'); ylabel('parcels 51:100')
nexttile; plot(lfo_lateral_diff, '.'); ylabel('symmetry test')

figure(3);
plot(phys_diff, '.');
title(['MAP - LFO average correlations across parcels 1:50 with ' taskOI ' and ' delay_range 's delay range'])





