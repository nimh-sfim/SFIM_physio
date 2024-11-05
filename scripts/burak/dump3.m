clear
load vitalsnew.mat 
load gmsig.mat

maprest_neg=maprest_fmri;
maprest_neg(maprest_fmri>mean(maprest_fmri))=mean(maprest_fmri);



nshift=0
scatter(normalize(maprest_fmri((1+nshift):end)),normalize(gm_rest(1:end-nshift)))
hold on


subplot(2,1,1)
plot(get_boldperc(gm_rest))
subplot(2,1,2)
plot(maprest_neg)