clear;%this code will get csf wm and gm signals
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
% basepath=['/data/akinb2/allbp/'];
basepath=['/data/SFIM_physio/data/'];
fname='func_rest';
% pname='follow_ROI_aeseg.nii';
gstr=load_untouch_nii('/vf/users/SFIM_physio/scripts/burak/MNIgmreg.nii');
gimaj=single(gstr.img)/max(single(gstr.img(:)));dimmo=size(gimaj);
gimmat=reshape(gimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);

wstr=load_untouch_nii('/vf/users/SFIM_physio/scripts/burak/MNIwmreg.nii');
wimaj=single(wstr.img)/max(single(wstr.img(:)));dimmo=size(wimaj);
wimmat=reshape(wimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);

cstr=load_untouch_nii('/vf/users/SFIM_physio/scripts/burak/MNIcsfreg.nii');
cimaj=single(cstr.img)/max(single(cstr.img(:)));dimmo=size(cimaj);
cimmat=reshape(cimaj,[dimmo(1)*dimmo(2)*dimmo(3) 1]);


load bpvals; %sys %dia
[~,sind]=sort(bpvals(:,1));
[~,dind]=sort(bpvals(:,2));

cc=0;
csfmat=zeros([23 1200]);gmmat=csfmat;wmmat=gmmat;
for vv=10:32
    vv
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb04.','bp',num2str(vv,'%.02d'),'.r01.scale.nii');
str=load_untouch_nii(fullname);
imaj=single(str.img);
dimm=size(imaj);
imajmat=reshape(imaj,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);
imajmat(isnan(imajmat))=0;


csfmat(cc,1:dimm(4))=mean(imajmat(cimmat>0.5,:));
gmmat(cc,1:dimm(4))=mean(imajmat(gimmat>0.5,:));
wmmat(cc,1:dimm(4))=mean(imajmat(wimmat>0.5,:));
end




