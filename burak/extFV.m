clear;%by using rigidbody
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
fname='BinH_mcf.nii';
pname='parcBinH.nii';
cc=0;
for vv=10:21
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname);
parcname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',pname);
[tcs,ov]=get_labeled_tc(fullname,parcname);
fv(cc,:)=normalize(ov(15,:));
end