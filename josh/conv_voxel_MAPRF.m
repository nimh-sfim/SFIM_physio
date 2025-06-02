% Convolve the response functions on a voxel-by-voxel basis with the
% subject's MAP timeseries and output these convolved regressors as a 4D
% NIFTI file. 

% Set up variables
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))
phys_type = 'MAP';          %MAP, lfo
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh

lmin = -9;
lmax = 18;
num_TR = 4;
TR = 0.75;
dl = TR * num_TR;     %in seconds
delay_range = strjoin([lmin "sto" lmax "s_dl" num_TR "TR"],'');
tarray_post = [lmin/TR : 1 : lmax/TR];  %in TR space

% Across subjects
%subjects = ["10"];
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);
    disp(strjoin(['Processing sub' sbjid],''))

    dir1 = strjoin(['/data/SFIM_physio/data/derivatives/sub' sbjid '/Resp_Func'],'');
    sbjid_brain_RF_file = strjoin([dir1 '/' sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_RespFunc_interp.nii'],'');

    dir2 = strjoin(['/data/SFIM_physio/data/bp' sbjid '/func_' task4let],'');
    sbjid_brain_raw_file = strjoin([dir2 '/pb04.bp' sbjid '.r01.scale.nii'],'');

    dir3 = '/data/SFIM_physio/physio/physio_results';
    map_file = strjoin([dir3,'/sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR_',taskOI,'.tsv'],'');

    % If statement tests if subject file exists
    if exist(sbjid_brain_RF_file, 'file') > 1
        % Load brain data (subject)
        sbjid_brain_RF = load_untouch_nii(char(sbjid_brain_RF_file));
        sbjid_brain_RF_img = sbjid_brain_RF.img;
    
        sbjid_brain_raw = load_untouch_nii(char(sbjid_brain_raw_file));
        sbjid_brain_raw_img = sbjid_brain_raw.img;

        % Load MAP
        map_data = readtable(map_file, "FileType", "text", 'Delimiter', '\t');
        map_ts = table2array(map_data(:,2));
        map_time = table2array(map_data(:,1));  %in seconds

        % Serialize
        dimRF = size(sbjid_brain_RF_img);
        submat_RF=reshape(squeeze(sbjid_brain_RF_img), [dimRF(1)*dimRF(2)*dimRF(3), dimRF(5)]);

        % Three phys datas were cut short, so set nvols accordingly
        dimraw = size(sbjid_brain_raw_img);
        if sbjid == "11" && strncmp(taskOI,'rest',4)
            dimraw(4) = 586;
            sbjid_brain_raw_img = sbjid_brain_raw_img(:,:,:,1:dimraw(4));
        elseif sbjid == "11" && strncmp(taskOI,'inhold',4)
            dimraw(4) = 586;
            sbjid_brain_raw_img = sbjid_brain_raw_img(:,:,:,1:dimraw(4));
        elseif sbjid == "26" && strncmp(taskOI,'outhold',4)
            dimraw(4) = 586;
            sbjid_brain_raw_img = sbjid_brain_raw_img(:,:,:,1:dimraw(4));
        end
        submat_raw=reshape(squeeze(sbjid_brain_raw_img), [dimraw(1)*dimraw(2)*dimraw(3), dimraw(4)]);

        % Convolve
        submat_conv=zeros(size(submat_RF,1), length(map_ts));     %initialize
        tarray_map = [1 : 1 : dimraw(4)];   %in TR
        map_ts_dm = map_ts - mean(map_ts);

        % Testing convolution with an impulse
        % impulse_test = zeros(1,37); impulse_test(1) = 1; %plot(impulse_test)
        % conv_test = conv(map_ts_dm, impulse_test, 'full');
        % start_idx = abs(tarray_post(1))+1;
        % conv_test = conv_test(start_idx : (length(map_ts_dm) + start_idx));
        % 
        % figure(1); tiledlayout(3,1); nexttile;
        % plot(map_ts_dm); ylabel('MAP'); title(sbjid); nexttile;
        % plot(impulse_test); ylabel('impulse'); nexttile;  % tarray_post
        % plot(conv_test); ylabel('convolved MAPximpulse');
        % 
        % figure(2);
        % plot(map_ts_dm, 'DisplayName', 'MAP'); title(sbjid); hold on;
        % plot(conv_test, 'DisplayName', 'convolved MAPximpulse'); legend();

        for jj=1:size(submat_raw,1)
            conv_1d = conv(map_ts_dm, submat_RF(jj,:), 'full');
            start_idx = abs(tarray_post(1))+1;
            conv_1d = conv_1d(start_idx : (length(map_ts_dm) + start_idx - 1));
            submat_conv(jj,:) = conv_1d;

            % if rem(jj, 100000) == 0
            %     disp(jj)    % let's see how fast it's processing the code
            % end
        end
        
        figure(ii); tiledlayout(3,1); nexttile;
        plot(map_ts_dm); ylabel('MAP'); title(sbjid); nexttile;
        plot(submat_RF(233730,:)); ylabel('RF'); nexttile;  % tarray_post
        plot(submat_conv(233730,:)); ylabel('convolved MAPxRF');

        % Put back into 4D space
        submat_conv_4d=reshape(submat_conv', [dimraw(1), dimraw(2), dimraw(3), dimraw(4)]);

        % Save NIFTIs
        cd(dir1)
        sbjid_brain_MAPRF_nii = sbjid_brain_raw;
        sbjid_brain_MAPRF_nii.img = submat_conv_4d;
        nii_filename = strjoin([sbjid '_' taskOI '_' phys_type '_lagged_' delay_range '_MAPRF_voxelwise.nii'],'');
        save_untouch_nii(sbjid_brain_MAPRF_nii, nii_filename)

        % Let's see if the NIFTI looks okay
        % voxelts_new = squeeze(sbjid_brain_MAPRF_nii_img(50,50,50,:));
        % plot(voxelts_new)

    else
        % File does not exist.
        warningMessage = sprintf('Warning: file does not exist:\n%s', sbjid_brain_raw_file);
        disp(warningMessage);
    end
end


