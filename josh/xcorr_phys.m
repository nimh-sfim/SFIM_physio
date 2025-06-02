% Plots the phys regressors as well as the GM average timeseries in BOLD
% data, after computing this average, in a 6x2 plot with all subjects

dir1 = '/data/SFIM_physio/physio/physio_results/';
dir2 = '/data/SFIM_physio/';
dir3 = '/data/SFIM_physio/data/derivatives/group/xcorr/';

% dependencies
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))    %On Biowulf

% Removed "11" at the moment because I have to re-create the MAP and LFO
% regressors. I had incorrectly considered the scan length in VOLUMES to be 439.50,
% not 586, which is in fact the true scan length in volumes, coinciding
% with 439.50 seconds. 

subjects = ["10","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
%subjects = ["18"];

corr_arr=zeros(1, length(subjects));
xcorr_gm_lfo_mat = zeros(length(subjects), 61);
xcorr_gm_map_mat = zeros(length(subjects), 61);
counter = 1;

for ii = 1:length(subjects)

    sbjid=char(subjects(ii));
    disp(['Processing sub' sbjid])

    %% Load masks
    cortical_mask = load_nii([dir2 '/atlases_rs/HarvardOxford-sub-maxprob-thr0-2mm_rs.nii']);
    cortical_mask_img = cortical_mask.img;
    cortical_mask_img_nan = cortical_mask_img;
    
    cortical_mask_img_nan(cortical_mask_img==2)=1000;       %GM mask will be values 13 and 2.
    cortical_mask_img_nan(cortical_mask_img==13)=1000;
    cortical_mask_img_nan(cortical_mask_img_nan<21)=NaN;
    cortical_mask_img_nan(cortical_mask_img_nan==1000)=1;
    
    % Load brain mask, as the GM mask extends past the brain. The GM mask probably isn't the optimal choice... 
    brain_mask = load_nii([dir2 '/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii']);
    brain_mask_img = brain_mask.img;
    brain_mask_img_nan = brain_mask_img;
    brain_mask_img_nan(brain_mask_img==0)=nan;
    
    % Load subject brain data
    sbjid_brain = load_nii([dir2 '/data/bp' sbjid '/func_rest/pb04.bp' sbjid '.r01.scale.nii']);
    sbjid_brain_img = sbjid_brain.img;
    
    %% Apply masks
    sbjid_brain_img_gm = sbjid_brain_img .* double(cortical_mask_img_nan);          %cortical GM mask
    sbjid_brain_img_gm_brain = sbjid_brain_img_gm .* double(brain_mask_img_nan);    %brain mask 
    
    %% Now, let's try to average
    dim=size(sbjid_brain_img_gm_brain);
    submat=reshape(sbjid_brain_img_gm_brain, [dim(1)*dim(2)*dim(3) dim(4)]);
    sbj_gm_avg_ts = mean(submat,1,'omitnan');
    sbj_gm_avg_ts_dm = sbj_gm_avg_ts - mean(sbj_gm_avg_ts);

    %% Load phys data and define plotting properties
    map_data_all = readtable([dir1,'sub',sbjid,'/','sub',sbjid,'_MAP_downsampled2TR.tsv'], "FileType","text",'Delimiter', '\t');
    map_data_all = table2array(map_data_all);
    time_array_map = map_data_all(:,1);
    map_data = map_data_all(:,2);
    map_data = map_data';

    card_data_all = readtable([dir1,'sub',sbjid,'/','sub',sbjid,'_lfo_test_downsampled2TR.tsv'], "FileType","text",'Delimiter', '\t');
    card_data_all = table2array(card_data_all);
    time_array_lfo = card_data_all(:,1);
    card_data = card_data_all(:,2);
    card_data = card_data';
    
    folder2 = strjoin([dir1,"sub",sbjid,"/"],'');
    cd(folder2);

    card_data_dm = card_data - mean(card_data);
    map_data_dm = map_data - mean(map_data);
    
    %% Plot LFO, MAP, and GM avg
    color1 = [170, 57, 57] / 255; 
    color2 = [46, 65, 114] / 255; 
    color3 = [170, 170, 57] / 255; 
    line_width = 2;
    font_size = 12;

    fig1 = figure(ii);
    t = tiledlayout(2,1);
    ax1 = nexttile; 
    yyaxis left
    plot(time_array_lfo, card_data,'Color',color1,'linewidth',line_width,'HandleVisibility','off')
    ylim([min(card_data)-0.01, max(card_data)+0.01])
    yticks([min(card_data) max(card_data)])
    xlim([0,time_array_lfo(end)])
    ax=gca;
    set(gca,'YColor','k');
    ylabel({['sub' sbjid],'LFO',},'Color',color1);
    title(['sub' sbjid])
    ax.FontSize = font_size;

    yyaxis right
    plot(time_array_map, map_data,'Color',color2,'linewidth',line_width,'HandleVisibility','off')
    ylim([min(map_data)-0.1, max(map_data)+0.1])
    xlim([0,(time_array_map(end))])
    ax=gca;
    set(gca,'YColor','k');
    set(gca,'XColor','k');
    ylabel('MAP','Color',color2);
    ax.FontSize = font_size;
    
    ax2 = nexttile;
    plot(sbj_gm_avg_ts_dm,'Color',color3,'linewidth',line_width,'HandleVisibility','off')
    ylabel('Avg GM DM','Color',color3);

    cd(dir3)
    title(t, "sub" + sbjid)
    fig_filename = strjoin(["sub" sbjid "_LFO_MAP_GM_ts.fig"],'');
    savefig(fig_filename)

    %% Correlation between MAP and LFO
    if length(map_data_dm) == length(card_data_dm)
        corr_val = corr([card_data_dm; map_data_dm]');
        corr_arr(counter) = corr_val(1,2);
    else
        disp('WARNING: PHYS TRACES DONT HAVE SAME LENGTHS')
        if length(map_data_dm) < length(card_data_dm)
            corr_val = corr([card_data_dm(1:length(map_data_dm)); map_data_dm]');
            corr_arr(counter) = corr_val(1,2);
        elseif length(map_data_dm) > length(card_data_dm)
            corr_val = corr([card_data_dm; map_data_dm(1:length(card_data_dm))]');
            corr_arr(counter) = corr_val(1,2);
        end
    end

    %% Define lags
    max_lag = 30;               % Maximum lag to consider
    lags = -max_lag:max_lag;    % Range of lags
    % If from -30 + 30, including 0, then length is 61

    %% Correlation between MAP and GM
    correlations = zeros(size(lags)); % Preallocate for correlation values
    x=sbj_gm_avg_ts_dm;
    y=map_data_dm;

    %% Compute Pearson correlation at each lag
    for jj = 1:length(lags)
        lag = lags(jj);
        y_shifted = circshift(y, lag); % Shift signal y by the current lag
        correlations(jj) = corr(x', y_shifted'); % Compute Pearson correlation
    end
    xcorr_gm_map=correlations;

    %% Correlation between LFO and GM
    correlations = zeros(size(lags)); % Preallocate for correlation values
    x=sbj_gm_avg_ts_dm;
    y=card_data_dm;
    for kk = 1:length(lags)
        lag = lags(kk);
        y_shifted = circshift(y, lag); % Shift signal y by the current lag
        correlations(kk) = corr(x', y_shifted'); % Compute Pearson correlation
    end
    xcorr_gm_lfo = correlations;
    xcorr_gm_lfo_mat(counter, :) =  xcorr_gm_lfo;
    xcorr_gm_map_mat(counter, :) =  xcorr_gm_map;

    counter = counter + 1;

end

cd(dir3)
filename2save_map = "xcorr_gm_map_mat.tsv";
writematrix(xcorr_gm_map_mat, filename2save_map, 'filetype','text', 'delimiter','\t')
filename2save_lfo = "xcorr_gm_lfo_mat.tsv";
writematrix(xcorr_gm_lfo_mat, filename2save_lfo, 'filetype','text', 'delimiter','\t')

%% For correlation between MAP and LFO
fisher_z_arr = atanh(corr_arr);     % Convert pearson correlation coefficient to Fisher Z
mean(fisher_z_arr);                 % Calculate mean
std(fisher_z_arr);                  % Calculate standard deviation


