clear;
basepath='/Volumes/data/allbp/bp'
subid=[11 12 13 14 15 16 17 18 19 20 21];

ii=1
fpath=strcat(basepath,num2str(subid(ii),'%0.2d'),'/vitals.mat');
load(fpath);

HRrest=hrrest_fmri;HRin=hrin_fmri;HRout=hrout_fmri;
MAPrest=maprest_fmri;MAPin=mapin_fmri;MAPout=mapout_fmri;

maplim=[80 120];hrlim=[40 80];
subplot(1,3,1); scatter(HRrest,MAPrest); ylim(maplim);xlim(hrlim)
subplot(1,3,2); scatter(HRin,MAPin);ylim(maplim);xlim(hrlim)
subplot(1,3,3); scatter(HRout,MAPout);ylim(maplim);xlim(hrlim)

