% This scripts calculates the average correlation across parcels and
% networks for MAP under different regression out parameters

% Set up variables
clc;clear;
addpath(genpath('data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))

phys_type= 'MAP';
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh
ROI_locations = 'Vis2';     %Som4, Som6, Vis2

%% Load group NIFTIs -- decided to use the non-masked NIFTIs
dir1='/data/SFIM_physio/data/derivatives/group_funccorr/';
cd(dir1)

group_MAP1D_fname = ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-MAP1D.nii'];
group_MAP1D = load_untouch_nii(group_MAP1D_fname);
group_MAP1D_img = group_MAP1D.img;
group_MAPxRF_fname =  ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-MAPxRF.nii'];
group_MAPxRF = load_untouch_nii(group_MAPxRF_fname);
group_MAPxRF_img = group_MAPxRF.img;
group_nah_fname =  ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-nah.nii'];
group_nah = load_untouch_nii(group_nah_fname);
group_nah_img = group_nah.img;

%% Load 100 parcel map
atlpath='/data/SFIM_physio/scripts/YEO100.nii';
atlas = load_untouch_nii(char(atlpath));
atlas_img = atlas.img;

%%
group_MAP1D_mat = [];
for ii = 1 : max(atlas_img(:))
    group_MAP1D_parcel = group_MAP1D_img(atlas_img==ii);
    group_MAP1D_mat = [group_MAP1D_mat; {group_MAP1D_parcel}];
end

group_MAPxRF_mat = [];
for ii = 1 : max(atlas_img(:))
    group_MAPxRF_parcel = group_MAPxRF_img(atlas_img==ii);
    group_MAPxRF_mat = [group_MAPxRF_mat; {group_MAPxRF_parcel}];
end

group_nah_mat = [];
for ii = 1 : max(atlas_img(:))
    group_nah_parcel = group_nah_img(atlas_img==ii);
    group_nah_mat = [group_nah_mat; {group_nah_parcel}];
end

%% Generate parcel averaged correlations
% Pad with NaN's
% There should be same lengths for all 3 regression conditions, so just choosing MAP1D
length_mat = [];
for jj = 1:length(group_MAP1D_mat)
    length(group_MAP1D_mat{jj});
    length_mat = [length_mat; length(group_MAP1D_mat{jj})];
end
len2padto = max(length_mat);

group_MAP1D_mat_sz = [];
for kk = 1:length(group_MAP1D_mat)
    tmp1 = [group_MAP1D_mat{kk}; NaN(len2padto-length(group_MAP1D_mat{kk}),1)]';
    group_MAP1D_mat_sz = [group_MAP1D_mat_sz; tmp1];  %same size rows in matrix, non-cell, format
end
group_MAP1D_avg = mean(group_MAP1D_mat_sz', 1, 'omitnan');

group_MAPxRF_mat_sz = [];
for kk = 1:length(group_MAPxRF_mat)
    tmp2 = [group_MAPxRF_mat{kk}; NaN(len2padto-length(group_MAPxRF_mat{kk}),1)]';
    group_MAPxRF_mat_sz = [group_MAPxRF_mat_sz; tmp2];  %same size rows in matrix, non-cell, format
end
group_MAPxRF_avg = mean(group_MAPxRF_mat_sz', 1, 'omitnan');

group_nah_mat_sz = [];
for kk = 1:length(group_nah_mat)
    tmp3 = [group_nah_mat{kk}; NaN(len2padto-length(group_nah_mat{kk}),1)]';
    group_nah_mat_sz = [group_nah_mat_sz; tmp3];  %same size rows in matrix, non-cell, format
end
group_nah_avg = mean(group_nah_mat_sz', 1, 'omitnan');


%% Plots
MAP1D_lateral_diff = group_MAP1D_avg(1:50) - group_MAP1D_avg(51:100);
nah_lateral_diff = group_nah_avg(1:50) - group_nah_avg(51:100);

% Next, consider MAPxRF vs. MAP1D
MAPxRF_lateral_diff = group_MAPxRF_avg(1:50) - group_MAPxRF_avg(51:100);
phys_diff2 = group_MAPxRF_avg(1:50) - group_MAP1D_avg(1:50);
fig1 = figure(1);
subplot(3,3,1); plot(group_MAPxRF_avg(1:50), '.'); ylabel('MAPxRF 1:50')
subplot(3,3,2); plot(group_MAPxRF_avg(51:100), '.'); ylabel('MAPxRF 51:100')
subplot(3,3,3); plot(MAPxRF_lateral_diff, '.'); ylabel('MAPxRF symmetry')
subplot(3,3,4); plot(group_MAP1D_avg(1:50), '.'); ylabel('MAP1D 1:50')
subplot(3,3,5); plot(group_MAP1D_avg(51:100), '.'); ylabel('MAP1D 51:100')
subplot(3,3,6); plot(MAP1D_lateral_diff, '.'); ylabel('MAP1D symmetry')
subplot(3,3,[7,8,9]); plot(phys_diff2, '.'); ylabel('MAPxRF - MAP1D')
sgtitle(['Average correlations across parcels for ' taskOI ' and ' ROI_locations ' seed'])
saveas(fig1,['MAPxRF_MAP1D_' taskOI '_' ROI_locations '_avg_corr_parcels.png'])

% Next, consider MAPxRF vs. NAH
phys_diff3 = group_MAPxRF_avg(1:50) - group_nah_avg(1:50);
fig2 = figure(2);
subplot(3,3,1); plot(group_MAPxRF_avg(1:50), '.'); ylabel('MAPxRF 1:50')
subplot(3,3,2); plot(group_MAPxRF_avg(51:100), '.'); ylabel('MAPxRF 51:100')
subplot(3,3,3); plot(MAPxRF_lateral_diff, '.'); ylabel('MAPxRF symmetry')
subplot(3,3,4); plot(group_nah_avg(1:50), '.'); ylabel('NAH 1:50')
subplot(3,3,5); plot(group_nah_avg(51:100), '.'); ylabel('NAH 51:100')
subplot(3,3,6); plot(nah_lateral_diff, '.'); ylabel('NAH symmetry')
subplot(3,3,[7,8,9]); plot(phys_diff3, '.'); ylabel(['MAPxRF - NAH'])
sgtitle(['Average correlations across parcels for ' taskOI ' and ' ROI_locations ' seed'])
saveas(fig2,['MAPxRF_NAH_' taskOI '_' ROI_locations '_avg_corr_parcels.png'])

%% Not plotting at the moment: consider MAP1D vs. raw
% phys_diff1 = group_MAP1D_avg(1:50) - group_nah_avg(1:50);
% figure(7); tiledlayout(3,1)
% nexttile; plot(group_MAP1D_avg(1:50), '.'); ylabel('parcels 1:50')
% title(['Average correlations across parcels for MAP1D with ' taskOI ' and ' ROI_locations ' seed'])
% nexttile; plot(group_MAP1D_avg(51:100), '.'); ylabel('parcels 51:100')
% nexttile; plot(MAP1D_lateral_diff, '.'); ylabel('symmetry test')
% 
% figure(8); tiledlayout(3,1)
% nexttile; plot(group_nah_avg(1:50), '.'); ylabel('parcels 1:50')
% title(['Average correlations across parcels for NAH with ' taskOI ' and ' ROI_locations ' seed'])
% nexttile; plot(group_nah_avg(51:100), '.'); ylabel('parcels 51:100')
% nexttile; plot(nah_lateral_diff, '.'); ylabel('symmetry test')
% 
% figure(9);
% plot(phys_diff1, '.');
% title(['MAP1D - RAW average correlations across parcels 1:50 with ' taskOI ' and ' ROI_locations ' seed'])


