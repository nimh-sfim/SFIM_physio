% This script plots the lagged cross correlations of MAP or LFO wrt
% the subject-level averaged GM timeseries, averaged across the group level
% with confidence intervals plotted. 
% This script replaces plot_confidence_interval_josh.py

phys_type = "lfo";    %options: 'lfo' or 'map'
filename = strjoin(["xcorr_gm_" phys_type "_mat.tsv"],'');
dir1 = "/Volumes/SFIM_physio/data/derivatives/group/xcorr/";
cd(dir1)

xcorr_mat = readtable(filename, "FileType","text",'Delimiter', '\t');
xcorr_mat = table2array(xcorr_mat);
time_array = linspace(-30, 30, 61);   %how many TRs to shift across the regressors
time_array_sec = time_array*0.75;        %for plotting purposes, converting to seconds

% Momentarily, the last two rows only have 0's? NEED TO RESOLVE THIS LATER
xcorr_mat = xcorr_mat(1:20,:);

%% Plotting each subject's xcorr line
t = tiledlayout(2,1)
nexttile
for ii = 1:size(xcorr_mat, 1) % across the subjects included in the analysis
    plot(time_array_sec, xcorr_mat(ii,:)); hold on;
end
xlim([time_array_sec(1), time_array_sec(end)])
ylabel('Pearson Correlation Coefficient')

%% Plotting group-averaged signal with confidence interval
confidence = 1.96; 

% Calculate the mean and standard deviation along the rows (i.e., across signals)
mean_signal = mean(xcorr_mat, 1);
std_dev_signal = std(xcorr_mat, 1);

% Calculate the confidence interval
ci_upper = mean_signal + confidence * (std_dev_signal / sqrt(size(xcorr_mat, 1)));
ci_lower = mean_signal - confidence * (std_dev_signal / sqrt(size(xcorr_mat, 1)));

% Plot averaged signal with shaded confidence interval
nexttile
h1 = plot(time_array_sec, mean_signal, 'Color', 'b');
hold on; 
h2 = patch([time_array_sec fliplr(time_array_sec)], [ci_lower fliplr(ci_upper)], 'b', 'FaceAlpha', ...
    0.2, 'EdgeColor', [0.8 0.8 0.8]);
handlevec = [h1 h2];

% Mark minimum & maximum for LFO and maximum for MAP
if phys_type == "lfo"
    [val1, idx1] = min(mean_signal);
    xline(time_array_sec(idx1))
    text(time_array_sec(idx1), mean_signal(idx1), "[" + num2str(time_array_sec(idx1)) + ", " + num2str(mean_signal(idx1)) + "]")
    [val2, idx2] = max(mean_signal);
    xline(time_array_sec(idx2))
    text(time_array_sec(idx2), mean_signal(idx2), "[" + num2str(time_array_sec(idx2)) + ", " + num2str(mean_signal(idx2)) + "]")
elseif phys_type == "map"
    [val3, idx3] = max(mean_signal);
    xline(time_array_sec(idx3))
    text(time_array_sec(idx3), mean_signal(idx3), "[" + num2str(time_array_sec(idx3)) + ", " + num2str(mean_signal(idx3)) + "]")
end

% Label the plot
title(t, phys_type)
xlim([time_array_sec(1), time_array_sec(end)])
xlabel('Time (sec)')
ylabel('Pearson Correlation Coefficient')
legend(handlevec, strjoin(["Mean Signal for " phys_type],''), 'Confidence Interval');
