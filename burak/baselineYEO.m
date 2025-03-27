 atlpath='/Volumes/SFIM_physio/scripts/YEO100.nii';
 impath='/Volumes/SFIM_physio/scripts/burak/baseline_DIA_br.nii'


 atl=load_untouch_nii(atlpath);
 atlim=atl.img;
str=load_untouch_nii(impath);
imaj=str.img;

for cc=1:100
    vals=imaj(atlim==cc);

    stddevs(cc)=std(vals);
means(cc)=mean(vals);
end

[aa,bb]=sort(means);
clf
hold on;
for i = 1:100
    % x = i * ones(1, size(data_ordered, 1)); % X positions for data points
     % plot(x, data_ordered(:, i), '.'); % Add individual data points
    errorbar(i, means(bb(i)), stddevs(bb(i)), 'r', 'LineWidth', 1.5); % Add error bars
end
xlabel('Columns (Ordered by idx)');
ylabel('Values');
title('Box Plot of Data (Ordered by idx)');
hold off;