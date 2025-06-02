function [input1_masked,input2_masked,Rsq,Z,coefs_slope,coefs_int] = spatialcorr_nonmedian(filename1,filename2,fix_intercept,mask_of_choice)
%SPATIALCORR

%%%%%%%%%%%
% Inputs:
%%%%%%%%%%
% filename1 = Full path to first map (e.g. HR map)
% filename2 = Full path to second map (e.g. mean arterial pressure map)
% fix_intercept = 0 or 1; Selecting this option will  output the slope 
% coefficient with the intercept fixed at 0. Otherwise, the intercept 
% term will be fit by the model too.
% mask_of_choice determines the mask to use (based on integer choice);

%% Read in MNI files
directory = '/data/SFIM_physio/';

cortical_mask = load_untouch_nii([directory 'atlases_rs/harvardoxford-cortical_bin_rs.nii']);

%cortical_mask = load_untouch_nii([directory 'group_hr/3dMEMA_hr.nii']);

cortical_mask_img = cortical_mask.img;
cortical_mask_img_nan = cortical_mask_img;
cortical_mask_img_nan(cortical_mask_img==0)=nan;
n_voxels=size(cortical_mask_img_nan,1)*size(cortical_mask_img_nan,2)*size(cortical_mask_img_nan,3);
cortical_mask_img_nan_reshape=reshape(cortical_mask_img_nan,[1,n_voxels]);

brainstem_mask = load_untouch_nii([directory 'atlases_rs/HarvardOxford-sub-maxprob-thr0-2mm_rs.nii']);
brainstem_mask_img = brainstem_mask.img;
brainstem_mask_img_nan = brainstem_mask_img;
brainstem_mask_img_nan(brainstem_mask_img==0)=nan;
n_voxels=size(brainstem_mask_img_nan,1)*size(brainstem_mask_img_nan,2)*size(brainstem_mask_img_nan,3);
brainstem_mask_img_nan_reshape=reshape(brainstem_mask_img_nan,[1,n_voxels]);

if mask_of_choice == 1
    mask_of_choice_img = cortical_mask_img_nan_reshape;
elseif mask_of_choice == 2
    mask_of_choice_img = brainstem_mask_img_nan_reshape;
end

%% Read in data
input1=filename1;
input2=filename2;

input1_nii=load_untouch_nii(input1);
input1_img=input1_nii.img;
input1_img_reshape=reshape(input1_img(:,:,:,1,1),[1,n_voxels]);

input2_nii=load_untouch_nii(input2);
input2_img=input2_nii.img;
input2_img_reshape=reshape(input2_img(:,:,:,1,1),[1,n_voxels]);

%% Create matrices of values within the mask

input1_masked = input1_img_reshape(mask_of_choice_img==1);
input2_masked = input2_img_reshape(mask_of_choice_img==1);

%???
% Normalize (scaled to the maximum value) <-- SHOULD I DO THIS STEP?
% input1_masked = input1_masked / max(input1_masked);
% input2_masked = input2_masked / max(input2_masked);

%% Compute correlations

if fix_intercept == 1
    mdl=fitlm(input1_masked,input2_masked,'Intercept',false); % fix intercept at 0
    %Rsq=mdl.Rsquared.Ordinary; 
    R=corrcoef(input1_masked,input2_masked);
    Rsq=R(2)*R(2);
    coefs_slope=mdl.Coefficients.Estimate(2);
    coefs_int=mdl.Coefficients.Estimate(1);    
else
    mdl=fitlm(input1_masked,input2_masked); % allow intercept to vary
    %Rsq=mdl.Rsquared.Ordinary; 
    R=corrcoef(input1_masked,input2_masked);
    Rsq=R(2)*R(2);
    coefs_slope=mdl.Coefficients.Estimate(2);
    coefs_int=mdl.Coefficients.Estimate(1);
end

% Convert R2 to Fisher's Z
% Fisher's Z reference: https://dx.doi.org/10.4135/9781412952644.n175
% atanh() is equivalent to: 0.5*log((1+R)/(1-R))
Z=atanh(sqrt(Rsq));

end

