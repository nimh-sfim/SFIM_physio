%% Violin plots of MAP, HRV, and RESP delay distributions in rs-fMRI data

dir='/Volumes/SFIM_physio/data/derivatives';

subjects = ["10","11","12","13","14","15","16","17","18","19","20","21"];

hbi_nifti_masked_matrix = [];  %zeros([1050624 length(subjects)]);
RMSSD_nifti_masked_matrix = [];
MAP_nifti_masked_matrix = [];
RESP_nifti_masked_matrix = [];

for subj_idx = 1:length(subjects)

    sbjid = subjects(subj_idx)

    dir_rapidtide=strcat(dir,'/sub',sbjid,'/rapidtide');
    hbi_filename=strcat(dir_rapidtide, '/cardiac/', 'sub', sbjid, '_resting_card_HBI_delay_desc-maxtime_map');
    hbi_nifti = niftiread(hbi_filename);

    RMSSD_filename=strcat(dir_rapidtide, '/cardiac2/', 'sub', sbjid, '_resting_card_RMSSD_delay_desc-maxtime_map');
    RMSSD_nifti = niftiread(RMSSD_filename);

    MAP_filename=strcat(dir_rapidtide, '/blood_pressure_old/', 'sub', sbjid, '_resting_MAP_delay_desc-maxtime_map');
    MAP_nifti = niftiread(MAP_filename);

    if sbjid == "11" || sbjid == "12"
        RESP_nifti = zeros(size(hbi_nifti_masked));
    else
        RESP_filename=strcat(dir_rapidtide, '/respiration/', 'sub', sbjid, '_resting_resp_delay_desc-maxtime_map');
        RESP_nifti = niftiread(RESP_filename);
    end

    
    %mask
    MNI_nifti = niftiread('/Volumes/SFIM_physio/atlases_rs/MNI152_T1_2mm_brain_mask_rs.nii');
    MNI_nifti = double(MNI_nifti);
    MNI_nifti(MNI_nifti == 0) = NaN; %arryyy(arryyy==0)=[]    
    hbi_nifti_masked = hbi_nifti .* MNI_nifti;
    RMSSD_nifti_masked = RMSSD_nifti .* MNI_nifti;
    MAP_nifti_masked = MAP_nifti .* MNI_nifti;
    RESP_nifti_masked = RESP_nifti .* MNI_nifti;
    
    % Serialize
    dim=size(hbi_nifti_masked);
    hbi_nifti_masked_lin=reshape(hbi_nifti_masked, [dim(1)*dim(2)*dim(3) 1]);
    hbi_nifti_masked_matrix = [hbi_nifti_masked_matrix, hbi_nifti_masked_lin];  %making into matrix because it's easier to plot this way
    
    RMSSD_nifti_masked_lin=reshape(RMSSD_nifti_masked, [dim(1)*dim(2)*dim(3) 1]);
    RMSSD_nifti_masked_matrix = [RMSSD_nifti_masked_matrix, RMSSD_nifti_masked_lin];  %making into matrix because it's easier to plot this way

    MAP_nifti_masked_lin=reshape(MAP_nifti_masked, [dim(1)*dim(2)*dim(3) 1]);
    MAP_nifti_masked_matrix = [MAP_nifti_masked_matrix, MAP_nifti_masked_lin];  %making into matrix because it's easier to plot this way
    
    RESP_nifti_masked_lin=reshape(RESP_nifti_masked, [dim(1)*dim(2)*dim(3) 1]);
    RESP_nifti_masked_matrix = [RESP_nifti_masked_matrix, RESP_nifti_masked_lin];  %making into matrix because it's easier to plot this way
    
end

names_cells = {'sub10','sub11','sub12','sub13','sub14','sub15','sub16','sub17','sub18','sub19','sub20','sub21'};
no_names_cells = {[],[],[],[],[],[],[],[],[],[],[],[]};
font_size = 30;

%% Sort based on IQR
% Step 1: Calculate IQR for each dataset
IQR_HRV = zeros(1, size(hbi_nifti_masked_matrix, 2));  % Array to store IQR values
for ii = 1:size(hbi_nifti_masked_matrix, 2)
    IQR_HRV(ii) = iqr(hbi_nifti_masked_matrix(:, ii));  % Calculate IQR for each dataset
end

IQR_MAP = zeros(1, size(MAP_nifti_masked_matrix, 2));  % Array to store IQR values
for ii = 1:size(MAP_nifti_masked_matrix, 2)
    IQR_MAP(ii) = iqr(MAP_nifti_masked_matrix(:, ii));  % Calculate IQR for each dataset
end

IQR_RESP = zeros(1, size(RESP_nifti_masked_matrix, 2));  % Array to store IQR values
for ii = 1:size(RESP_nifti_masked_matrix, 2)
    IQR_RESP(ii) = iqr(RESP_nifti_masked_matrix(:, ii));  % Calculate IQR for each dataset
end

% Sort the datasets based on IQR
[~, sortedIdx_HRV] = sort(IQR_HRV, 'descend');
[~, sortedIdx_MAP] = sort(IQR_MAP, 'descend');
[~, sortedIdx_RESP] = sort(IQR_RESP, 'descend');

% Reorder the data columns based on sortedIdx
hbi_nifti_masked_matrix_sorted = hbi_nifti_masked_matrix(:, sortedIdx_HRV);
MAP_nifti_masked_matrix_sorted = MAP_nifti_masked_matrix(:, sortedIdx_MAP);
RESP_nifti_masked_matrix_sorted = RESP_nifti_masked_matrix(:, sortedIdx_RESP);

MAP_CRIS = [81, 102.3333333, 78.33333333, 78.33333333, 80.33333333, 83, 83, 86.33333333, 84.33333333, 88, 83, 106]; %from subj10-21

%% Sorted boxplot
figure(1)
tiledlayout(3,1);
nexttile
boxplot(hbi_nifti_masked_matrix_sorted, 'symbol', '')      %removes outliers, since it makes the boxplot rather unreadable
ylim([-8 8]);
ylabel({'HRV'; '(seconds)'})
xticklabels(no_names_cells)
set(gca,'fontsize', font_size) 
title('Delay Distributions')

nexttile
%subplot(3,1,2)
boxplot(MAP_nifti_masked_matrix_sorted, 'symbol', '')
ylim([-8 8]);
ylabel({'MAP'; '(seconds)'})
xticklabels(no_names_cells)
set(gca,'fontsize', font_size) 

nexttile
%subplot(3,1,3)
boxplot(RESP_nifti_masked_matrix_sorted, 'symbol', '')
ylim([-8 8]);
ylabel({'RVT'; '(seconds)'})
xlabel('Subjects')
xticklabels(no_names_cells)
set(gca,'fontsize', font_size)

%% Double Plot
figure(2)
yyaxis left
boxplot(MAP_nifti_masked_matrix_sorted, 'symbol', '')
ylim([-8 8]);
ylabel({'MAP Delay Distributions'; '(seconds)'})
xticklabels(no_names_cells)
set(gca,'fontsize', font_size) 

yyaxis right
plot(MAP_CRIS(sortedIdx_MAP), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
ylabel('MAP from CRIS (mmHg)')

set(gca,'fontsize', font_size)

%% scatterplot
figure(3)
IQR_sort = IQR_MAP(sortedIdx_MAP);
MAP_sort = MAP_CRIS(sortedIdx_MAP);
scatter(IQR_sort, MAP_sort, 150, 'filled');      %3rd argument is the markersize
xlabel('IQR of MAP Delay Distributions (sec)'); ylabel('MAP from CRIS (mmHg)')

mdl=fitlm(IQR_sort,MAP_sort); % allow intercept to vary
R=corrcoef(IQR_sort,MAP_sort);
Rsq=R(2)*R(2);
coefs_slope=mdl.Coefficients.Estimate(2);
coefs_int=mdl.Coefficients.Estimate(1);

lower_lim = min(IQR_sort);     %min([min(IQR_sort),min(MAP_sort)])
upper_lim = max(IQR_sort);
xref=(lower_lim-1) : (upper_lim-lower_lim)/45 : (upper_lim+1);
yref=coefs_slope(1)*xref + coefs_int(1);
hold on; plot(xref,yref,'Color', 'b', 'linewidth', 2,'HandleVisibility','off')
xlim([lower_lim-1, upper_lim+1]);

% Text on plot
Rsqstr=num2str(sqrt(Rsq(1)),'%.2f');
slope_str=num2str(coefs_slope(1),'%.2f');
str1 = strcat('R = ', Rsqstr)
str2 = strcat('\beta = ', slope_str)

text(4,100, str1,'Color', 'b','Fontsize', 25)
text(4,96, str2,'Color', 'b','Fontsize', 25)

set(gca,'fontsize', font_size)






%% No longer using code below... 
%subplot(3,1,1); hist(hbi_nifti_masked_matrix(:,4)); subplot(3,1,2); boxplot(hbi_nifti_masked_matrix(:,4), 'symbol', ''); subplot(3,1,3); boxplot(hbi_nifti_masked_matrix(:,4), 'symbol', '')


%% Unsorted violin plot
% figure(1)
% subplot(3,1,1)
% distributionPlot(hbi_nifti_masked_matrix, 'color', [1 0 0], 'histOpt', 1, 'yLabel', {'HRV'; '(seconds)'}, 'xNames', no_names_cells, 'showMM', 0)
% ylim([-8 8]);
% set(gca,'fontsize', font_size)
% title('Unsorted violin plot')
% % subplot(3,1,2)
% % distributionPlot(RMSSD_nifti_masked_matrix, 'color', [1 0 0], 'histOpt', 1)
% subplot(3,1,2)
% distributionPlot(MAP_nifti_masked_matrix, 'color', [0 1 0], 'histOpt', 1, 'yLabel', {'MAP'; '(seconds)'}, 'xNames', no_names_cells, 'showMM', 0)
% %ylim([-20 20]);
% ylim([-8 8]);
% set(gca,'fontsize', font_size) 
% subplot(3,1,3)
% distributionPlot(RESP_nifti_masked_matrix, 'color', [0 0 1], 'histOpt', 1, 'yLabel', {'RVT'; '(seconds)'}, 'xNames', names_cells, 'showMM', 0)
% ylim([-8 8]);
% set(gca,'fontsize', font_size) 
% 
% %% Sorted violin plot
% figure(2)
% subplot(3,1,1)
% distributionPlot(hbi_nifti_masked_matrix_sorted, 'color', [1 0 0], 'histOpt', 1, 'yLabel', {'HRV'; '(seconds)'}, 'xNames', no_names_cells, 'showMM', 0)
% ylim([-8 8]);
% set(gca,'fontsize', font_size) 
% title('Sorted violin plot')
% % subplot(3,1,2)
% % distributionPlot(RMSSD_nifti_masked_matrix, 'color', [1 0 0], 'histOpt', 1)
% subplot(3,1,2)
% distributionPlot(MAP_nifti_masked_matrix_sorted, 'color', [0 1 0], 'histOpt', 1, 'yLabel', {'MAP'; '(seconds)'}, 'xNames', no_names_cells, 'showMM', 0)
% %ylim([-20 20]);
% ylim([-8 8]);
% set(gca,'fontsize', font_size) 
% subplot(3,1,3)
% distributionPlot(RESP_nifti_masked_matrix_sorted, 'color', [0 0 1], 'histOpt', 1, 'yLabel', {'RVT'; '(seconds)'}, 'showMM', 0)
% ylim([-8 8]);
% set(gca,'fontsize', font_size) 
% 
% %% Unsorted boxplot
% figure(3)
% tiledlayout(3,1);
% nexttile
% boxplot(hbi_nifti_masked_matrix, 'symbol', '')      %removes outliers, since it makes the boxplot rather unreadable
% ylim([-8 8]);
% ylabel({'HRV'; '(seconds)'})
% xticklabels(no_names_cells)
% set(gca,'fontsize', font_size) 
% title('Unsorted boxplot')
% 
% nexttile
% %subplot(3,1,2)
% boxplot(MAP_nifti_masked_matrix, 'symbol', '')
% ylim([-8 8]);
% ylabel({'MAP'; '(seconds)'})
% xticklabels(no_names_cells)
% set(gca,'fontsize', font_size) 
% 
% nexttile
% %subplot(3,1,3)
% boxplot(RESP_nifti_masked_matrix, 'symbol', '')
% ylim([-8 8]);
% ylabel({'RVT'; '(seconds)'})
% xticklabels(names_cells)
% set(gca,'fontsize', font_size)






%% The text histogram files look funny... Not sure what's up with them as they don't match what's shown in tidepool, so no longer using... 
% card_filename_woext=strcat([dir_rapidtide, '/cardiac/', 'sub', sbjid, '_resting_card_HBI_delay_desc-maxtime_hist']);
% card_filename_wextgz=strcat([card_filename_woext, '.tsv.gz']);
% card_filename_wexttsv=strcat([card_filename_woext, '.tsv']);
% if isfile(card_filename_wexttsv)
%     disp('.tsv file exists')
% else
%     gunzip(card_filename_wextgz)
% end
% distributionPlot(hbi_nifti)

%% Playing around with the type of data used to convert 0 --> NaN
% %uint32 doesn't work... double does work... 
% A = [1 1 0 1 1 0 0 1];
% A = double(A)
% %A = uint32(A)
% A(A == 0) = NaN

%% Example code for the violin plot
% r = rand(1000,1);
% rn = randn(1000,1)*0.38+0.5;
% rn2 = [randn(500,1)*0.1+0.27;randn(500,1)*0.1+0.73];
% rn2=min(rn2,1);rn2=max(rn2,0);
% figure
% ah(1)=subplot(2,4,1:2);
% boxplot([r,rn,rn2])
% ah(2)=subplot(2,4,3:4);
% distributionPlot([r,rn,rn2],'histOpt',2); % histOpt=2 works better for uniform distributions than the default
% set(ah,'ylim',[-1 2])
% %--additional options
% data = [randn(100,1);randn(50,1)+4;randn(25,1)+8];
% subplot(2,4,5)
% distributionPlot(data); % defaults
% subplot(2,4,6)
% distributionPlot(data,'colormap',copper,'showMM',5,'variableWidth',false) % show density via custom colormap only, show mean/std,
% subplot(2,4,7:8)
% distributionPlot({data(1:5:end),repmat(data,2,1)},'addSpread',true,'showMM',false,'histOpt',2) %auto-binwidth depends on # of datapoints; for small n, plotting the data is useful
