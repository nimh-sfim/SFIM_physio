clear;
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
% fname='BinH_mcf.nii';
fname='BouH_mcf.nii';
% fname='Rest_mcf.nii';

for vv=10
    vv
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname);
% outname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/BinH_mcf_filt');
outname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/BouH_mcf_filt');
% outname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/Rest_mcf_filt');

str=load_untouch_nii(fullname);
imaj=str.img;
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);


srate=1/(2*(0.75));
[b,a] = cheby2(4,40,[0.01 0.1]/srate,'bandpass');

otc_filt = filtfilt(b,a,double(imajmat)')';
imajnew=reshape(otc_filt,[dimm(1) dimm(2) dimm(3) dimm(4)]);
% mstr=load_untouch_nii(strcat(basepath,'bp',num2str(vv,'%.02d'),'/BinH_mean.nii'));
mstr=load_untouch_nii(strcat(basepath,'bp',num2str(vv,'%.02d'),'/BouH_mean.nii'));
% mstr=load_untouch_nii(strcat(basepath,'bp',num2str(vv,'%.02d'),'/Rest_mean.nii'));

imajmean=mstr.img;
str.img=imajnew+imajmean;
save_untouch_nii(str,outname)
end




