clear;%by using rigidbody
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
fname='func_rest';
% pname='follow_ROI_aeseg.nii';
cc=0;
for vv=10:21
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb03.','bp',num2str(vv,'%.02d'),'.r01.volreg.nii');
str=load_untouch_nii(fullname);
imaj=single(str.img);
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);
[perc] = get_boldperc(imajmat);
imo(:,cc)=var(perc')';
end
imo(:,8)=[];
maprest=mat2variable('maprest.mat');
meanmap=mean(maprest');

corrm=corr(imo',meanmap');

corim=reshape(corrm,[dimm(1) dimm(2) dimm(3)]);

