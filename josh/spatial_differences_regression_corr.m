% Investigates the voxelwise spatial pattern of the differences between the
% regressing out approaches

% Set up variables
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
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

%% Save the difference maps (probs easier to use 3dcalc, but whatevs)
upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
uim=load_untouch_nii(upath);

group_MAPxRF_MAP1D = group_MAP1D; group_MAPxRF_nah = group_MAP1D; % initialize
group_MAPxRF_MAP1D.img = group_MAPxRF_img - group_MAP1D_img;
group_MAPxRF_nah.img = group_MAPxRF_img - group_nah_img;

% Save NIFTI
fname_out_MAPxRF_MAP1D = ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-group_MAPxRF_minus_MAP1D'];
save_untouch_nii(group_MAPxRF_MAP1D, fname_out_MAPxRF_MAP1D)
% Mask
mask_nii(upath,[fname_out_MAPxRF_MAP1D '.nii'],[fname_out_MAPxRF_MAP1D '_masked']);

% Save NIFTI
fname_out_MAPxRF_nah = ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-group_MAPxRF_minus_nah'];
save_untouch_nii(group_MAPxRF_nah, fname_out_MAPxRF_nah)
% Mask
mask_nii(upath,[fname_out_MAPxRF_nah '.nii'],[fname_out_MAPxRF_nah '_masked']);


