clear;%this code will get
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
% basepath=['/data/akinb2/allbp/'];
basepath=['/data/SFIM_physio/data/'];
fname='func_rest';
% pname='follow_ROI_aeseg.nii';
cc=0;
gstr=load_untouch_nii('/vf/users/SFIM_physio/scripts/burak/MNIgmreg.nii.gz');
gimaj=single(gstr.img)/max(single(gstr.img(:)));dimmo=size(gimaj);
gimmat=reshape(gimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);

load bpvals; %sys %dia
[~,sind]=sort(bpvals(:,1));
[~,dind]=sort(bpvals(:,2));
msk=gimmat>0.5;
for vv=10:32
    vv
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb04.','bp',num2str(vv,'%.02d'),'.r01.scale.nii');
str=load_untouch_nii(fullname);
imaj=single(str.img);
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);
imajmat(isnan(imajmat))=0;
mmat=mean(imajmat,2);
vmat=var(imajmat')';

cvmat=vmat./mmat;
imo(:,cc)=cvmat(msk);
end




