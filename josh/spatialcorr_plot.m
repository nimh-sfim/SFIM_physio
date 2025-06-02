%% Plotting spatial correlations

%orange     --> [248, 118, 109]/255;
%teal       --> [0, 191, 196]/255;
%yellow     --> [255, 165, 0] / 255
color = [255, 165, 0] / 255;

figure(1)

line_width = 2.5;
font_size = 35;

scatter(input1_masked{1}, input2_masked{1},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',color,'LineWidth',2) %'MarkerFaceAlpha',0.8, 'MarkerEdgeAlpha',0.8)
hold on

lower_lim = min([min(input1_masked{1}),min(input2_masked{1})]);
upper_lim = max([max(input1_masked{1}),max(input2_masked{1})]);
xref=lower_lim : (upper_lim-lower_lim)/45 : upper_lim;
yref=coefs_slope(1)*xref + coefs_int(1);
plot(xref,yref,'Color',color, 'linewidth', line_width,'HandleVisibility','off')
hold on; plot(xref, xref, 'Color', [0.5 0.5 0.5], 'linewidth', line_width,'HandleVisibility','off')   
Rsqstr=num2str(sqrt(Rsq(1)),'%.2f');
slope_str=num2str(coefs_slope(1),'%.2f');
str1 = strcat('R = ', Rsqstr)
str2 = strcat('\beta = ', slope_str)

ses_pos = 0.5;
text(-0.5*upper_lim,ses_pos*upper_lim, str1,'Color',color,'Fontsize',font_size)
text(0.1*upper_lim,-ses_pos*upper_lim, str2,'Color',color,'Fontsize',font_size)

xlabel('HR');       %map1
ylabel('MAP');      %map2
% string1='MAP vs. HR in mask %s';
% string2=sprintf(string,str(mask_of_choice))
title(sprintf('MAP vs. HR in mask %s', string(mask_of_choice)))

ax=gca;
ax.FontSize = font_size;

axis square
axis tight
grid on
grid minor

