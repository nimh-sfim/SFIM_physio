% Used for OHBM in Dec. 2024

clear;

addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/load_acq'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))

upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
uim=load_untouch_nii(upath);
slices=10:7:80; %ax
under=row_nii(uim.img,slices,3)';      %axial view

cd('/data/SFIM_physio/scripts')
opath='MAP_maxcorr_rapidtide_group.nii';    %lfo_maxcorr_rapidtide_group.nii OR MAP_maxcorr_rapidtide_group.nii
oim=load_untouch_nii(opath);

oim_masked = mask_nii(uim.img,oim.img);

over=row_nii(oim_masked,slices,3)';
%over=row_nii(oim.img,slices,3)';

minval=-1;maxval=1;         %lower and upper range
valn=0; valp=0;        %zero means no negative threshold
%valn=-0.5; valp=0.5;        %zero means no negative threshold
clustn=0;clustp=0;          %cluster threshold;

finalim=overlay_nii(under,over,minval,valn,valp,maxval,clustn,clustp);

dir1 = '/data/SFIM_physio/data';
cd([dir1 '/pics_OHBM'])    %Save all the results at the same place

imagesc(finalim)
%image(finalim)
%imwrite(finalim, ['group_' opath '_ax.jpeg']);

%title([opath])
