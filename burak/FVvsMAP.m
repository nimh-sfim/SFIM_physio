mapin=mat2variable('mapin.mat');
mapout=mat2variable('mapout.mat');
maprest=mat2variable('maprest.mat');


vin=var(mapin');
vou=var(mapout');
vre=var(maprest');

hmat=cat(1,vre,vin,vou)
xlim([0 3])


load('afni_fv.mat')
afni_binh(8,:)=[];
afni_bouh(8,:)=[];
afni_rest(8)=[];
 for kk=1:11
dump=cell2mat(afni_rest(kk));
afni_restn(kk,:)=dump(1:800);
 end


clf;sub=3
plot(normalize(maprest(sub,:)));
hold on
plot(normalize(afni_restn(sub,:)));
 for sub=1:11
rc(sub)=corr(maprest(sub,:)',afni_restn(sub,:)');
ouc(sub)=corr(mapout(sub,:)',afni_bouh(sub,:)');
inc(sub)=corr(mapin(sub,:)',afni_binh(sub,:)');


 end


