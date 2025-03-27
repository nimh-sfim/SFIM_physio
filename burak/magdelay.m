%this code maps the relation of magnitude and delay
clc;clear;

addpath(genpath('/Volumes/SFIM/akin/bin/burak'));
addpath(genpath('/Volumes/SFIM/akin/bin/NIfTI_20140122'))

    upath='/Volumes/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
    uim=load_untouch_nii(upath);uimg=uim.img;


imdump=zeros([96 114 96]);

LFOpath1='/Volumes/SFIM_physio/scripts/burak/LFOcorr_br.nii'
LFOpath2='/Volumes/SFIM_physio/scripts/burak/LFOtime_br.nii'
str1=load_untouch_nii(LFOpath1);img1=str1.img;
str2=load_untouch_nii(LFOpath2);img2=str2.img;

img1(uimg==0)=[];img2(uimg==0)=[];
scatter(img2,img1,'.')
set( gca, 'fontname', 'arial', 'fontsize', 20, 'fontweight', 'bold')
xlabel('seconds')
ylabel('correlation coefficient')
title('Non-Pulsatile PPG Magnitude Delay relation')

MAPpath1='/Volumes/SFIM_physio/scripts/burak/MAPcorr_br.nii'
MAPpath2='/Volumes/SFIM_physio/scripts/burak/MAPtime_br.nii'
mstr1=load_untouch_nii(MAPpath1);mimg1=mstr1.img;
mstr2=load_untouch_nii(MAPpath2);mimg2=mstr2.img;

mimg1(uimg==0)=[];mimg2(uimg==0)=[];
scatter(mimg2,mimg1,'.')