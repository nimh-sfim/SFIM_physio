clear;
load outresponse_perc.mat
load outresponse_demean.mat


sub=4;
clf
yyaxis right
plot(linspace(0,550,5500),mapoutresponse(sub,:),'LineWidth',2)
ylabel('mmHg')

yyaxis left
plot(linspace(0,550,5500),gmoutresponse(sub,:),'LineWidth',2)
ylabel('% BOLD')
%  ylim([2 -1]);

xlabel('seconds')
set(gca,'FontSize',20)
saveas(gcf,strcat('./figs/outsub_',num2str(sub,'%0.2d'),'.png'))