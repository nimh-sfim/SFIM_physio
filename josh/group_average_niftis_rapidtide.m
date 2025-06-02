%group average rapidtide results from the maxtime_map.nii.gz maxcorr_map.nii.gz file
%Editing this on 4/9/25 to see if I can re-create group results
clc;clear;

addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf
%addpath(genpath('/Users/deanjn/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/Tools for NIfTI and ANALYZE image'))

%% Define the folder path based on phys_type
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];
phys_type= 'MAP';   %lfo, MAP
taskOI = 'resting'; %resting, inhold, outhold
delay_range='1030';   %10, 20
                    %note: 10 is for (-10 10)

%% Load anatomical MNI
upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
uim=load_untouch_nii(upath);

imdump_delay=zeros([96 114 96]);
imdump_corr=zeros([96 114 96]);

counter = 0;
for ii = 1:length(subjects)
    sbjid=char(subjects(ii));
    if phys_type == 'MAP'
        bpath=['/data/SFIM_physio/data/derivatives/sub' sbjid '/rapidtide/blood_pressure9/'];
        fname_delay= ['sub' sbjid '_' taskOI '_' phys_type '_delay_' delay_range '_desc-maxtime_map.nii.gz'];
        fname_corr= ['sub' sbjid '_' taskOI '_' phys_type '_delay_' delay_range '_desc-maxcorr_map.nii.gz'];
    elseif phys_type == 'lfo'
        bpath=['/data/SFIM_physio/data/derivatives/sub' sbjid '/rapidtide/cardiac_lfo9/'];
        fname_delay= ['sub' sbjid '_' taskOI '_card_' phys_type '_delay_' delay_range '_desc-maxtime_map.nii.gz'];
        fname_corr= ['sub' sbjid '_' taskOI '_card_' phys_type '_delay_' delay_range '_desc-maxcorr_map.nii.gz'];
    else
        disp('something funny happened when assigning phys file')
    end

    opath_delay=[bpath fname_delay];
    opath_corr=[bpath fname_corr];

    if exist(opath_delay, 'file') && exist(opath_corr, 'file')
        % File exists.  Do stuff....
        oim_delay=load_untouch_nii(opath_delay);    % subject's map
        imdump_delay=imdump_delay+oim_delay.img;    % group map
        oim_corr=load_untouch_nii(opath_corr);      % subject's map
        imdump_corr=imdump_corr+oim_corr.img;       % group map
        counter = counter + 1;
    else
      % File does not exist.
      warningMessage = sprintf('Warning: file does not exist:\n%s', opath_delay);
      disp(warningMessage);
    end
end

%% Divide "group" maps by the number of subjects
dir_out='/data/SFIM_physio/data/derivatives/group_rapidtide3.0/'
cd(dir_out)

oim_delay.img=imdump_delay/counter;
imagesc(squeeze(imdump_delay(:,:,48))/counter)

oim_corr.img=imdump_corr/counter;
imagesc(squeeze(imdump_corr(:,:,48))/counter)

if phys_type == 'MAP'
    %Save NIFTI
    save_untouch_nii(oim_delay,['MAP_time_' taskOI '_' delay_range '_group'])
    save_untouch_nii(oim_corr,['MAP_corr_' taskOI '_' delay_range '_group'])
    %Mask
    mask_nii(upath,['MAP_time_' taskOI '_' delay_range '_group.nii'],['MAP_time_' taskOI '_' delay_range '_group_mask']);
    mask_nii(upath,['MAP_corr_' taskOI '_' delay_range '_group.nii'],['MAP_corr_' taskOI '_' delay_range '_group_mask']);
elseif phys_type == 'lfo'
    %Save NIFTI
    save_untouch_nii(oim_delay,['LFO_time_' taskOI '_' delay_range '_group'])
    save_untouch_nii(oim_corr,['LFO_corr_' taskOI '_' delay_range '_group'])
    %Mask
    mask_nii(upath,['LFO_time_' taskOI '_' delay_range '_group.nii'],['LFO_time_' taskOI '_' delay_range '_group_mask']);
    mask_nii(upath,['LFO_corr_' taskOI '_' delay_range '_group.nii'],['LFO_corr_' taskOI '_' delay_range '_group_mask']);
end

