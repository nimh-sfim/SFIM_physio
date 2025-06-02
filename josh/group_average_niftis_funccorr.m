% group average functional connectivity results after running seedbased_josh.m

% Set up variables
clc;clear;
addpath(genpath('data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))

subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];
phys_type= 'MAP';   %lfo, MAP
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh
ROI_locations = 'Vis2';     %Som4, Som6, Vis2
phys_types='nah';         %MAP1D, MAPxRF, nah

%% Load anatomical MNI
upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
uim=load_untouch_nii(upath);

imdump=zeros([96 114 96]);

counter = 0;

%% Start loop
for ii = 1:length(subjects)
    sbjid=char(subjects(ii));
    
    dir1 = ['/data/SFIM_physio/data/derivatives/sub' sbjid '/func_' task4let '_MAPRF_out'];
    
    % for kk = 1:length(phys_types)
    % 
    %     for jj = 1:length(ROI_locations)

    fname  = ['sub' sbjid '_' taskOI '_ROI-' ROI_locations '_regropt-' phys_types '.nii'];

    opath=[dir1 '/' fname];

    if exist(opath, 'file')
        % File exists.  Do stuff....
        oim=load_untouch_nii(opath);  % subject's map
        imdump = imdump + oim.img;    % group map
        counter = counter + 1;
    else
      % File does not exist.
      warningMessage = sprintf('Warning: file does not exist:\n%s', opath);
      disp(warningMessage);
    end
end

%% Divide "group" maps by the number of subjects
dir_out='/data/SFIM_physio/data/derivatives/group_funccorr/';
cd(dir_out)

oim.img=imdump/counter;
imagesc(squeeze(imdump(:,:,48))/counter)

% Save NIFTI
fname_out = ['group_MAP_funccorr_' taskOI '_ROI-' ROI_locations '_regropt-' phys_types];
save_untouch_nii(oim,fname_out)
% Mask
mask_nii(upath,[fname_out '.nii'],[fname_out '_masked']);


