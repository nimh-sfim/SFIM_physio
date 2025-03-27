%plot network lags

addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
[tcs,overalltcs]=get_labeled_tc('sub12orig.nii','7NETREG.nii');
str=load_untouch_nii('sub12orig.nii');

out='sub12orig.nii'

sbix=[10 12 13 14 15 16 17 18 19 20 21 ];

matdump=zeros([96 114 96 266]);
for x=1:11
x
% fname=strcat('sub' ,num2str(sbix(x)), '_resting_card_lfo_delay_desccorrout_info.nii');
fname=strcat('sub' ,num2str(sbix(x)), '_resting_MAP_delay_desccorrout_info.nii');

str=load_untouch_nii(fname);
size(str.img);
matdump=matdump+str.img;
end
str.img=matdump/11;
save_untouch_nii(str,'avgDelaymap')




