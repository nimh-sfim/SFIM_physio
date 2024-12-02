dstr=load_untouch_nii('100ParcelsREG.nii');
imaj=dstr.img;

DMN=[1:14 (1:14)+50];%default -->1
CON=[15:19 (15:19)+50];%frontoparietal -->2
LMB=[20:23 (20:23)+50];%limbic -->3
SAL=[24:28 74:78 93];%Saliance or ventral attention -->4
DAN=[29:35 79 81:85];%Dorsal attention -->5
SOM=[36:43 80 86:92];%Motor -->6
VIS=[44:50 (44:50)+50];%Visual -->7

nimaj=zeros(size(imaj));
for xx=1:length(DMN)
nimaj(imaj==DMN(xx))=1;
end

for xx=1:length(CON)
nimaj(imaj==CON(xx))=2;
end

for xx=1:length(LMB)
nimaj(imaj==LMB(xx))=3;
end

for xx=1:length(SAL)
nimaj(imaj==SAL(xx))=4;
end

for xx=1:length(DAN)
nimaj(imaj==DAN(xx))=5;
end

for xx=1:length(SOM)
nimaj(imaj==SOM(xx))=6;
end

for xx=1:length(VIS)
    nimaj(imaj==VIS(xx))=7;
end

dstr.img=nimaj;
save_untouch_nii(dstr,'7NETREG')

