clear;%this code will get csf wm and gm signals
addpath(genpath('/Volumes/SFIM/akin/bin/burak'));
addpath(genpath('/Volumes/SFIM/akin/bin/NIfTI_20140122'));
% basepath=['/Volumes/akinb2/allbp/'];
basepath=['/Volumes/SFIM_physio/data/'];
fname='func_rest';
% pname='follow_ROI_aeseg.nii';
gstr=load_untouch_nii('/Volumes/SFIM_physio/scripts/burak/MNIgmreg.nii');
gimaj=single(gstr.img)/max(single(gstr.img(:)));dimmo=size(gimaj);
gimmat=reshape(gimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);

wstr=load_untouch_nii('/Volumes/SFIM_physio/scripts/burak/MNIwmreg.nii');
wimaj=single(wstr.img)/max(single(wstr.img(:)));dimmo=size(wimaj);
wimmat=reshape(wimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);

cstr=load_untouch_nii('/Volumes/SFIM_physio/scripts/burak/MNIcsfreg.nii');
cimaj=single(cstr.img)/max(single(cstr.img(:)));dimmo=size(cimaj);
cimmat=reshape(cimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);




for vv=12
    vv
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb04.','bp',num2str(vv,'%.02d'),'.r01.scale.nii');
str=load_untouch_nii(fullname);
imaj=single(str.img);
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);
imajmat(isnan(imajmat))=0;

gmmat=mean(imajmat(gimmat>0.5,:));
end

regstr=load_untouch_nii('sub12_resting_card_lfo_delay_desc-lfofilterCleaned_bold.nii.gz')
regimaj=single(cstr.img);regimajmat=reshape(regimaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);

gmmat2=mean(regimajmat(gimmat>0.5,:));



% optimal shift is 12 TRs =9sec

optimalLFO=circshift(lfo,12);
Y=gmmat'; X=[optimalLFO ones(length(optimalLFO),1)];
[B,BINT,R] = regress(Y,X);
% [B,BINT,R] = regress(Y,[X1 ones(length(optimalLFO),1)]);


[P,S] = polyfit(optimalLFO,Y,1)