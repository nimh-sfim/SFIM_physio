% Creates design matrices for each subject for MAP +- lmax, by dl increments
% Note: we're no longer using the sine wave approach. 

%% Load regressor and set conditions
clc;clear;
taskOI='resting';           %resting, inhold, outhold
dir1 = '/data/SFIM_physio/physio/physio_results';
sine_conv = 0;              %binary, 1 for yes, 0 for no. 1 If choose to use sine waves instead of eye matrix

%% Create an eye matrix that determines the shifted start times
% Note for when choosing lmax, lmin, and dl: (lmax-lmin)/dl must be an integer
% num_TR sets the spacings between the ones

% Choose one of the six options below
num_TR=6; lmax = 18; lmin = -9;
% num_TR=5; lmax = 17.25; lmin = -9;
% num_TR=4; lmax = 18; lmin = -9;
% num_TR=3; lmax = 18; lmin = -9;
% num_TR=2; lmax = 18; lmin = -9;
% num_TR=1; lmax = 18; lmin = -9;

dl = 0.75 * num_TR;
delay_range = strjoin([lmin "sto" lmax "s_dl" dl "s"],'');

% Now that the variables are defined, generate the matrix
if num_TR > 1
    id_matrix = zeros(((lmax-lmin)/dl)+1);
    for ii = 1:((lmax-lmin)/dl)+1
        id_matrix(ii, ii + (ii-1) * (num_TR-1)) = 1;
    end
    id_matrix = id_matrix';
elseif num_TR == 1
    id_matrix = eye(((lmax-lmin)/dl)+1);
end

%% Define sine waves (8 with different period counts)
N = ((lmax-lmin)/dl)+1;
tarray = [lmin:dl:lmax];

if sine_conv == 1
    tiledlayout(8,1);
    nexttile; % 1: cos with 1 period over N volumes
    cos1 = cos((tarray-lmin)/(lmax-lmin)*2*pi); plot(tarray,cos1);
    nexttile; % 2: sin with 1 period over N volumes
    sin1 = sin((tarray-lmin)/(lmax-lmin)*2*pi); plot(tarray,sin1);
    nexttile; % 3: cos with 2 periods over N volumes
    cos2 = cos((tarray-lmin)/(lmax-lmin)*4*pi); plot(tarray,cos2);
    nexttile; % 4: sin with 2 periods over N volumes
    sin2 = sin((tarray-lmin)/(lmax-lmin)*4*pi); plot(tarray,sin2);
    nexttile; % 5: cos with 3 periods over N volumes
    cos3 = cos((tarray-lmin)/(lmax-lmin)*6*pi); plot(tarray,cos3);
    nexttile; % 6: sin with 3 periods over N volumes
    sin3 = sin((tarray-lmin)/(lmax-lmin)*6*pi); plot(tarray,sin3);
    nexttile; % 7: cos with 4 periods over N volumes
    cos4 = cos((tarray-lmin)/(lmax-lmin)*8*pi); plot(tarray,cos4);
    nexttile; % 8: sin with 4 periods over N volumes
    sin4 = sin((tarray-lmin)/(lmax-lmin)*8*pi); plot(tarray,sin4);
end

%% Define subject list
% subjects = ["10"];
if strncmp(taskOI,'rest',4)
    %resting: skip 17,28,29,33
    subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","26","27","30","31","32","34"];
elseif strncmp(taskOI,'inhold',4)
    %inhold: skip 10,17,26,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","27","28","30","31","32","33","34"];
elseif strncmp(taskOI,'outhold',4)
    %outhold: skip 10,17,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
end

%% Run loop
for ii = 1:length(subjects)
    
    % Subject MAP data
    sbjid = subjects(ii);
    map_file = strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR_',taskOI,'.tsv'],'');
    map_data = readtable(map_file, "FileType", "text", 'Delimiter', '\t');
    map_ts = table2array(map_data(:,2));
    map_time = table2array(map_data(:,1));
    map_ts_dm = map_ts - mean(map_ts);

    design_matrix_pre = padarray(id_matrix, length(map_ts_dm) - (((lmax-lmin)/dl)+1), 0, "post");
    design_matrix_pre = design_matrix_pre(1:length(map_ts_dm),:);

    %% Let's determine the nvols from the text file instead of reading in the NIFTI file
    nvols_table = readtable('/data/SFIM_physio/scripts/nifti_volumes.txt');
    nvols_sbj = nvols_table(:,1);
    nvols_task = nvols_table.Properties.VariableNames(2:4);
    
    expected_col_names = ["Subjects","bouh","binh","rest"];
    for kk = 1:length(nvols_table.Properties.VariableNames)
        if strcmp(nvols_table.Properties.VariableNames(kk),expected_col_names(kk)) == 0
            disp(['WARNING: COLUMN NAMES OF NVOLS TABLE DO NOT MEET MY EXPECTATIONS, index: ', num2str(kk), '.']); disp('THIS MAY INDICATE THAT IM USING THE WRONG NVOLS.')
        end
    end
    
    if strncmp(taskOI, 'outhold', 4)
        colOI = 2;      %task_tmp = 'bouh'
    elseif strncmp(taskOI, 'inhold', 4)
        colOI = 3;      %task_tmp = 'binh'
    elseif strncmp(taskOI, 'resting', 4)
        colOI = 4;      %task_tmp = 'rest'
    end
    rowOI = str2num(sbjid) - 10 + 1;
    nvols = table2array(nvols_table(rowOI, colOI));
    
    % Three phys datas were cut short, so set nvols accordingly
    if sbjid == "11" && strncmp(taskOI,'rest',4)
        nvols = 586;
    elseif sbjid == "11" && strncmp(taskOI,'inhold',4)
        nvols = 586;
    elseif sbjid == "26" && strncmp(taskOI,'outhold',4)
        nvols = 586;
    end
    lenofMAP = nvols;

    if sine_conv == 1
        % Convolve the non-shifted MAP regressor with each of the 8 different sine waves, s.t. for sub15 for example, I'd have a 1200x8 matrix
        MAP_cos1 = conv(map_ts_dm, cos1); MAP_cos1 = MAP_cos1(1:lenofMAP);
        MAP_sin1 = conv(map_ts_dm, sin1); MAP_sin1 = MAP_sin1(1:lenofMAP);
        MAP_cos2 = conv(map_ts_dm, cos2); MAP_cos2 = MAP_cos2(1:lenofMAP);
        MAP_sin2 = conv(map_ts_dm, sin2); MAP_sin2 = MAP_sin2(1:lenofMAP);
        MAP_cos3 = conv(map_ts_dm, cos3); MAP_cos3 = MAP_cos3(1:lenofMAP);
        MAP_sin3 = conv(map_ts_dm, sin3); MAP_sin3 = MAP_sin3(1:lenofMAP);
        MAP_cos4 = conv(map_ts_dm, cos4); MAP_cos4 = MAP_cos4(1:lenofMAP);
        MAP_sin4 = conv(map_ts_dm, sin4); MAP_sin4 = MAP_sin4(1:lenofMAP);
        design_matrix_post = [MAP_cos1'; MAP_sin1'; MAP_cos2'; MAP_sin2'; MAP_cos3'; ...
            MAP_sin3'; MAP_cos4'; MAP_sin4'];
        design_matrix_post = design_matrix_post';

        % Assign header names because AFNI expects the first row to be a header
        design_matrix_post_tab = array2table(design_matrix_post);

        % Plot figure
        figure(ii); tiledlayout(2,1);
        nexttile; plot(design_matrix_post); title(['sub' sbjid]); ylabel(sbjid)
        nexttile; imagesc(design_matrix_post); ylabel(sbjid)

        % Save with header cuz afni will otherwise not consider the first row of data
        %writetable(design_matrix_post_tab, strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_MAP_lagged_mat_',taskOI,'_' delay_range '_sinwaves.tsv'],''),'FileType','text','Delimiter','tab');

    else
        %% Convolution
        % Convolve MAP regressor to eye matrix to generate MAP lagged matrix
        design_matrix_post = zeros(size(design_matrix_pre));
        for ii = 1:size(design_matrix_pre,2)
            tmp = conv(map_ts_dm, id_matrix(:,ii), 'full'); %zeros should be present within the second column
            design_matrix_post(:,ii) = tmp((abs(lmin/dl)*num_TR+1):(lenofMAP+abs(lmin/dl)*num_TR));     %trim the end
        end
    
        % Assign header names because AFNI expects the first row to be a header
        design_matrix_post_tab = array2table(design_matrix_post);
    
        % Plot figure
        figure(ii); tiledlayout(2,1);
        nexttile; plot(design_matrix_post); title(['sub' sbjid]); ylabel(sbjid)
        nexttile; imagesc(design_matrix_post); ylabel(sbjid)

        % Save with header cuz afni will otherwise not consider the first row of data
        writetable(design_matrix_post_tab, strjoin([dir1,'/sub',sbjid,'/','sub',sbjid,'_MAP_lagged_mat_',taskOI,'_' delay_range '.tsv'],''),'FileType','text','Delimiter','tab');

    end
end


