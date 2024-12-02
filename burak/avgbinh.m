clear;%average Binh
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
fname='func_binh';
cc=0;
buc=zeros([96*114*96 800]);
for vv=10:21
cc=cc+1
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname,'/pb03.','bp',num2str(vv,'%.02d'),'.r01.volreg.nii');
str=load_untouch_nii(fullname);
dp=get_boldperc(reshape(str.img,[96*114*96 800]));
dp(isnan(dp))=0;
buc=buc+dp;
end
str.img=reshape(buc/cc,[96 114 96 800]);
save_untouch_nii(str,'./group/bouh_perc');