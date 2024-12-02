%plot network lags 
[tcs,overalltcs]=get_labeled_tc('press_wave.nii','7NETREG.nii');
% DMN=[1:14 (1:14)+50];%default
% CON=[15:19 (15:19)+50];%frontoparietal
% LMB=[20:23 (20:23)+50];%limbic
% SAL=[24:28 74:78 93];%Saliance or ventral attention
% DAN=[29:35 79 81:85];%Dorsal attention
% SOM=[36:43 80 86:92];%Motor
% VIS=[44:50 (44:50)+50];%Visual

DMNtcs=cell2mat(tcs(1));
CONtcs=cell2mat(tcs(2));
LMBtcs=cell2mat(tcs(3));
SALtcs=cell2mat(tcs(4));
DANtcs=cell2mat(tcs(5));
SOMtcs=cell2mat(tcs(6));
VIStcs=cell2mat(tcs(7));

timegrid=linspace(-10,30,266);

alltcs=[mean(DMNtcs);mean(CONtcs);mean(LMBtcs);mean(SALtcs);mean(DANtcs);mean(SOMtcs);mean(VIStcs)];
plot(timegrid,alltcs,'LineWidth',2);legend('DMN','CON','LMB','SAL','DAN','SOM','VIS')