% Create 4D NIFTI file of the same, subject-specific MAP regressors, NOT
% convolved. This is important because 3dcalc will later be used to regress
% the MAP timeseries on a *voxel-wise basis*, so I need the MAP timeseries
% arranged across these voxels. 

% Set up variables
clc;clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))
phys_type = 'MAP';          %MAP, lfo
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh

% Across subjects
%subjects = ["10"];
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);
    disp(strjoin(['Processing sub' sbjid],''))

    dir1 = strjoin(['/data/SFIM_physio/data/derivatives/sub' sbjid '/func_' task4let '_MAPRF_out'],'');

    dir2 = strjoin(['/data/SFIM_physio/data/bp' sbjid '/func_' task4let],'');
    sbjid_brain_raw_file = strjoin([dir2 '/pb04.bp' sbjid '.r01.scale.nii'],'');

    dir3 = '/data/SFIM_physio/physio/physio_results';
    map_file = strjoin([dir3,'/sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR_',taskOI,'.tsv'],'');

    % If statement tests if subject file exists
    if exist(sbjid_brain_raw_file, 'file') > 1 && exist(map_file, 'file') > 1
        % Load brain data (subject)
        sbjid_brain_raw = load_untouch_nii(char(sbjid_brain_raw_file));
        sbjid_brain_raw_img = sbjid_brain_raw.img;

        % Load MAP
        map_data = readtable(map_file, "FileType", "text", 'Delimiter', '\t');
        map_ts = table2array(map_data(:,2));
        map_time = table2array(map_data(:,1));  %in seconds

        % Serialize
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

        % Multiply MAP timeseries by matrix of ones
        submat_MAP=ones(size(submat_raw,1), length(map_ts));     %initialize
        map_ts_dm = map_ts - mean(map_ts);

        for jj=1:size(submat_raw,1)
            submat_MAP(jj,:) = map_ts_dm;
            % if rem(jj, 10000) == 0
            %     disp(jj)    % let's see how fast it's processing the code
            % end
        end
        
        % figure(ii); tiledlayout(2,1); nexttile;
        % plot(map_ts_dm); ylabel('MAP'); title(sbjid); nexttile;
        % plot(submat_MAP(233730,:)); ylabel('MAP from matrix');

        % Put back into 4D space
        submat_MAP_4d=reshape(submat_MAP', [dimraw(1), dimraw(2), dimraw(3), dimraw(4)]);

        % Save NIFTIs
        cd(dir1)
        sbjid_brain_MAP_nii = sbjid_brain_raw;
        sbjid_brain_MAP_nii.img = submat_MAP_4d;
        nii_filename = strjoin([sbjid '_' taskOI '_' phys_type '1D_same_voxelwise.nii'],'');
        save_untouch_nii(sbjid_brain_MAP_nii, nii_filename)

    else
        % File does not exist.
        warningMessage = sprintf('Warning: file does not exist:\n%s', sbjid_brain_raw_file);
        disp(warningMessage);
    end
end


