clear;%by using rigidbody
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
fname='func_rest';
pname='follow_ROI_aeseg.nii';
cc=0;
for vv=10:21
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb03.','bp',num2str(vv,'%.02d'),'.r01.volreg.nii');
parcname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/',pname);
[tcs,ov]=get_labeled_tc(fullname,parcname);
fv{cc}=normalize(ov(15,:));
end
afni_rest=fv;