clear;
load bpvals
% load csfboldperc.mat
load csfboldCV.mat
imo(isnan(imo))=0;

[aa,bb]=sort(bpvals(:,1));

% Reorder columns based on idx
data_ordered = imo(:,bb);

% Calculate statistics
means = mean(data_ordered, 1);
std_devs = std(data_ordered, 0, 1);

% Create the box plot
% boxplot(data_ordered, 'Labels', arrayfun(@(x) sprintf('Col %d', x), bb, 'UniformOutput', false));


% Overlay means and std deviations
clf
hold on;
for i = 1:size(data_ordered, 2)
    x = i * ones(1, size(data_ordered, 1)); % X positions for data points
     % plot(x, data_ordered(:, i), '.'); % Add individual data points
    errorbar(i, means(i), sqrt(std_devs(i)), 'r', 'LineWidth', 1.5); % Add error bars
end
xlabel('Columns (Ordered by idx)');
ylabel('Values');
title('Box Plot of Data (Ordered by idx)');
hold off;