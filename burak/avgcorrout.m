
clear;
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));

subjects = ["sub10","sub12","sub13","sub14","sub15","sub16","sub17","sub18","sub19","sub20","sub21"];

poolmat=zeros([1050624 1]);
for subj_idx = 1:length(subjects)

    sbjid = subjects(subj_idx);
    dir_subj = strcat('/data/SFIM_physio/data/derivatives/', sbjid, '/rapidtide/cardiac_lfo2');
    %dir_lag_times = strcat(dir_subj, '/', sbjid, '_resting_MAP_delay_desc-maxtime_map.nii.gz');
    dir_corr_fcn = strcat(dir_subj, '/', sbjid, '_resting_card_lfo_delay_desc-corrout_info.nii');

   str = load_untouch_nii(dir_corr_fcn);
    dim=size(corr_fcn);
    submat=reshape(corr_fcn, [dim(1)*dim(2)*dim(3) 1]);
    poolmat = poolmat + submat;
end

global resultmat
resultmat=reshape(poolmat/length(subjects),[dim(1) dim(2) dim(3) 1]);  % average of all

datatype = 64;
nii_result = make_nii(resultmat, [2 2 2], datatype);
% out_dir = '/data/SFIM_physio/data/derivatives/';
% cd out_dir

%save_nii(nii_result, "map_rapidtide_group");
save_nii(nii_result, 'MAP_maxcorr_rapidtide_group.nii');
%This outputs a NIFTI with incorrect header information, and Burak had
%fixed this for me. 

