% Used for OHBM in Dec. 2024
% visualize rapidtide results from the maxtime_map.nii.gz file

clc;clear;

addpath(genpath('/Volumes/SFIM/akin/bin/burak'));
addpath(genpath('/Volumes/SFIM/akin/bin/NIfTI_20140122'))
%addpath(genpath('/home/deanjn/Downloads/Tools for NIfTI and ANALYZE image'))    %On Biowulf
addpath(genpath('/Users/deanjn/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/Tools for NIfTI and ANALYZE image'))

%% Define the folder path based on phys_type
subjects = ["10","12","13","14","15","16","17","18","19","20","21"];
phys_type='MAP';

for ii = 1:length(subjects)

    sbjid=char(subjects(ii));
    
    if phys_type == 'MAP'
        bpath=['/Volumes/SFIM_physio/data/derivatives/sub' sbjid '/rapidtide/blood_pressure2'];
        fname= ['sub' sbjid '_resting_' phys_type '_delay_desc-maxtime_map.nii.gz'];
    elseif phys_type == 'lfo'
        bpath=['/Volumes/SFIM_physio/data/derivatives/sub' sbjid '/rapidtide/cardiac_lfo2'];
        fname= ['sub' sbjid '_resting_card_' phys_type '_delay_desc-maxtime_map.nii.gz'];
    else
        disp('something funny happened')
    end
    
    cd(bpath)
    
    %% Load anatomical MNI
    upath='/Volumes/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
    uim=load_untouch_nii(upath);
    slices=[48 48 48]; %sag cor ax
    usag=row_nii(uim.img,slices(1),1)';     %sagittal view
    ucor=row_nii(uim.img,slices(2),2)';     %coronal view
    uax=row_nii(uim.img,slices(3),3)';      %axial view
    
    under=cat(2,cat(1,ones([9 114]),usag,ones([9 114])),cat(1,ones([9 96]), ucor,ones([9 96])),... 
        uax); %pad and concat; generates underlying sag, cor, and axial view within one image
    
    %% Load the delay map of interest: this will be the overlay in the image
    opath=fullfile(bpath,fname);
    oim=load_untouch_nii(opath);
    
    osag=row_nii(oim.img,slices(1),1)';
    ocor=row_nii(oim.img,slices(2),2)';
    oax=row_nii(oim.img,slices(3),3)';
    
    %padding below should be with zeros...
    over=cat(2,cat(1,ones([9 114]),osag,ones([9 114])),cat(1,ones([9 96]),ocor,ones([9 96])),...
        oax); %pad and concat; generates overlay sag, cor, and axial view within one image
    
    over=mask_nii(under,over); %mask overlay based on underlay(anatomical)
    
    %% Plot
    minval=-10;maxval=30;  %lower and upper range
    valn=0; valp=0;        %zero means no negative threshold
    clustn=0;clustp=0;     %cluster threshold;
    finalim=overlay_nii(under,over,minval,valn,valp,maxval,clustn,clustp);
    
    imagesc(finalim)
    
    imwrite(finalim, ['sub' sbjid '_resting_' phys_type '_delay_maxtime_sagcorax_neg10-pos30.jpeg']);

end

