 clear;%load MAP save MAP
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
cc=0; clear mapmat
for vv=10:13
    cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/','vitalsnew.mat');
load(fullname);
    mapmat(cc,:)=maprest_fmri(1:800);
    
end
    
     for vv=[14 15 16  18 19 20 21];
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/','vitals.mat');
load(fullname);
mapmat(cc,:)=maprest_fmri(1:800);
     end

