clear;%get map corr in different freq
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
load mapout.mat

for vv=10:20
    vv
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/func_bouh/pb03.bp',num2str(vv,'%.02d'),'.r01.volreg.nii');
loname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/func_bouh/lomap',num2str(vv,'%.02d'));
hiname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/func_bouh/himap',num2str(vv,'%.02d'));
str=load_untouch_nii(fullname);
imaj=str.img;
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);

map=mapmat(vv-9,:);
srate=1/(2*(0.75));
[b,a] = cheby2(4,40,[0.01 0.15]/srate,'bandpass');
[b2,a2] = cheby2(4,40,[0.2 0.6]/srate,'bandpass');
lotc_filt = filtfilt(b,a,double(imajmat)')';
lomap=filtfilt(b,a,map);
hitc_filt = filtfilt(b2,a2,double(imajmat)')';
himap=filtfilt(b2,a2,map);

lcorr=corr(lotc_filt',lomap');
limaj=reshape(lcorr,[dimm(1) dimm(2) dimm(3) ]);

hcorr=corr(hitc_filt',himap');
himaj=reshape(hcorr,[dimm(1) dimm(2) dimm(3) ]);

str.hdr.dime.dim(1)=3;
str.hdr.dime.dim(5)=1;
str.img=limaj;
save_untouch_nii(str,loname)
str.img=himaj;
save_untouch_nii(str,hiname)
end

