load /Volumes/SFIM_physio/scripts/burak/sampreg.mat
Y=samplegm;X=[ones([1 length(shiftedlfo)]) ; shiftedlfo']';
[B,BINT,R] = regress(Y,X);

clf; subplot(2,1,1); plot(normalize(samplegm),'LineWidth',1.5); hold on
plot(normalize(shiftedlfo),'LineWidth',1.5);legend('Gray Matter','LFO');
set( gca, 'fontname', 'arial', 'fontsize', 14, 'fontweight', 'bold')
subplot(2,1,2); plot(normalize(samplegm),'LineWidth',1.5);hold on;
plot(normalize(R),'LineWidth',1.5); legend('Gray Matter','LFO regressed')
set( gca, 'fontname', 'arial', 'fontsize', 14, 'fontweight', 'bold')