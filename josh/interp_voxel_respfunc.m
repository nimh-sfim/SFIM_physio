% Interpolate the response functions on a voxel-by-voxel basis (cubic interpolation).
% At the moment, using 4TR shifts
% Make sure that the values pre-interpolating (at the lags with real data) 
% are the same values post-interpolating, so I'll be sure that I constrain
% the interpolating model in such a way where the datapoints don't change.

% Set up variables
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))
phys_type = 'MAP';          %MAP, lfo
taskOI='outhold';           %resting, inhold, outhold

lmin = -9;
lmax = 18;
num_TR = 4;
dl = 0.75 * num_TR;     %in seconds
num_dtp_in_ts = abs((lmin-lmax)/dl) + 1;
tarray_pre = linspace(1,num_dtp_in_ts,num_dtp_in_ts);  %in TR
delay_range = strjoin([lmin "sto" lmax "s_dl" num_TR "TR"],'');
tarray_post = [1 : 1/num_TR : num_dtp_in_ts];
ts_len_post = length(tarray_post);
%tarray_post = linspace(1,((lmax-lmin)+1),((lmax-lmin)+1));

% Across subjects
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);

    dir1 = strjoin(['/data/SFIM_physio/data/derivatives/sub' sbjid '/Resp_Func'],'');
    sbjid_brain_file = strjoin([dir1 '/' sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_RespFunc.nii'],'');
    submat_interp=zeros(1050624, length(tarray_post));     %initialize

    % If statement tests if subject file exists
    if exist(sbjid_brain_file, 'file') > 1
        % Load brain data (subject)
        sbjid_brain = load_untouch_nii(char(sbjid_brain_file));
        sbjid_brain_img = sbjid_brain.img;
        sbjid_brain_img_rm2 = sbjid_brain_img(:,:,:,1,3:end);   %first two are polort
    
        % Serialize
        dim = size(sbjid_brain_img_rm2);
        submat=reshape(squeeze(sbjid_brain_img_rm2), [dim(1)*dim(2)*dim(3), dim(5)]);
        
        % Interpolate
        submat_interp = interp1(tarray_pre', submat', tarray_post, 'cubic'); 
        
        % No longer use below because it's much faster if you change the sizes of the arrays
        % for jj=1:length(submat)
        %     tmp = interp1(tarray_pre, submat(jj,:), tarray_post, 'cubic');
        %     submat_interp = [tmp; submat_interp];
        % end
        % This shows that the values pre-interp are the same post-interp
        % voxel_ts = squeeze(sbjid_brain_img_rm2(70,50,63, 1, :));
        % voxel_ts_interp = interp1(tarray_pre, voxel_ts, tarray_post, 'cubic');
        % plot(voxel_ts, '.'); hold on; plot(tarray_post,voxel_ts_interp,'-');
        
        % Put back into 4D space
        submat_interp_4d=reshape(submat_interp', [dim(1),dim(2),dim(3),ts_len_post]);

        % Save NIFTIs
        cd(dir1)
        sbjid_brain_img_rm2_nii = sbjid_brain;
        sbjid_brain_img_rm2_nii.img = submat_interp_4d;
        nii_filename = strjoin([sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_RespFunc_interp.nii'],'');
        sbjid_brain_img_rm2_nii.hdr.dime.dim = [5,96,114,96,1,ts_len_post,1,1];
        %save_untouch_nii(sbjid_brain_img_rm2_nii, nii_filename)

        % Plot to just double check that things look okay
        % This shows that the values pre-interp are the same post-interp
        figure(ii)
        img1 = sbjid_brain.img;
        img2 = sbjid_brain_img_rm2_nii.img;
        voxel_ts = squeeze(img1(70,50,63, 1, 3:end));
        voxel_ts_interp = squeeze(img2(70,50,63, :));
        plot(voxel_ts, '.'); hold on; plot(tarray_post,voxel_ts_interp,'-'); title(sbjid)

    else
        % File does not exist.
        warningMessage = sprintf('Warning: file does not exist:\n%s', sbjid_brain_file);
        disp(warningMessage);
    end
end


%%
% After interpolating (in next script), 
% Generate subject-level response functions
% across all GM
% across Fstat thresholded GM
% across kmeans clustered voxels
% Perhaps try group-level response function, and see if there's too much variability across subjects?

