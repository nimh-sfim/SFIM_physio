clear;%get map corr in different freq
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];

limaj=zeros([96 114 96]);
himaj=zeros([96 114 96]);
for vv=10:20
    vv
loname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/func_binh/lomap',num2str(vv,'%.02d'),'.nii');
hiname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/func_binh/himap',num2str(vv,'%.02d'),'.nii');


lstr=load_untouch_nii(loname);
imajcurr=lstr.img;
limaj=limaj+imajcurr;


hstr=load_untouch_nii(hiname);
imajnow=hstr.img;
himaj=himaj+imajnow;

end
lstr.img=limaj/11;
save_untouch_nii(lstr,'loMAPcorr')
hstr.img=himaj/11;
save_untouch_nii(hstr,'hiMAPcorr')
