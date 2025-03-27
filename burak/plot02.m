clear;
% load inresponse_perc.mat
% load inresponse_demean.mat
clear;
load inresponse.mat
load outresponse.mat


sub=2;
clf
yyaxis right
plot(linspace(0,550,5500),mapinresponse(sub,:),'LineWidth',2)
ylabel('mmHg')

yyaxis left
plot(linspace(0,550,5500),gminresponse(sub,:),'LineWidth',2)
ylabel('% BOLD')
xlabel('seconds')
set(gca,'FontSize',20)
saveas(gcf,strcat('./figs/instdsub_',num2str(sub,'%0.2d'),'.png'))