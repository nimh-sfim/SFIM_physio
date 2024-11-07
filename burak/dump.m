clear;%load MAP
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
cc=0;
for vv=10:21
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/','vitals.mat');
load(fullname)

fv(cc,:)=normalize(ov(15,:));
end

mapin_fmrires=mapin_fmri;
mapout_fmrires=mapout_fmri;
maprest_fmrires=maprest_fmri;
mapin_fmri=interp1(linspace(0,1,60000),mapin_fmrires,linspace(0,1,800));
mapout_fmri=interp1(linspace(0,1,60000),mapout_fmrires,linspace(0,1,800));
maprest_fmri=interp1(linspace(0,1,112500),maprest_fmrires,linspace(0,1,1500));
