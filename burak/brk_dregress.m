function dataout=brk_dregress(data4D,lag3D,mask3D,phys1D)


%load data4D
dstr=load_untouch_nii('/Volumes/SFIM_physio/data/bp12/func_rest/sm_pb04.bp12.r01.scale.nii');
data4D=dstr.img;
dimm=dstr.hdr.dime.dim(2:5);
dmat=reshape(data4D,[dimm(1)*dimm(2)*dimm(3) dimm(4)]);

srate=1/(2/0.75);
[b,a] = cheby2(4,40,[0.008 0.1]/srate,'bandpass');
tcs_filt = filtfilt(b,a,dmat')';


%load lag3D
sbjid=12; phys_type='lfo';
  bpath=['/Volumes/SFIM_physio/data/derivatives/sub' num2str(sbjid) '/rapidtide/cardiac_lfo2'];
           fname= ['sub' num2str(sbjid) '_resting_card_' phys_type '_delay_desc-maxcorr_map.nii.gz'];
        % fname= ['sub' num2str(sbjid) '_resting_card_' phys_type '_delay_desc-maxtime_map.nii.gz'];
lstr=load_untouch_nii(fullfile(bpath,fname));
lmat=reshape(lstr.img,[dimm(1)*dimm(2)*dimm(3) 1]);

%load mask3D
    mpath='/Volumes/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
    mstr=load_untouch_nii(mpath);
    mmat=reshape(mstr.img,[dimm(1)*dimm(2)*dimm(3) 1]);

 %load phys1D
 addpath(genpath('/Volumes/SFIM/akin/bin/load_acq'))%adjust path if run on biowulf
nvols=dimm(4); % number of volumes 
scan_time=nvols*0.75;%TR=0.75sec
fileList = dir(fullfile('/Volumes/SFIM_physio/data/bp12/physio/', '*Rest*.acq'));%fetch file with Rest name under working folder
myacq=load_acq(fullfile(fileList.folder,fileList.name)); %load biopac data

%filter physio to get LFO
flow=0.01;fhigh=0.1;fsamp=500;
bp_chosen=myacq.data(1:(scan_time)*fsamp,2);%biopac chosen segment of PPG
ts_out=brk_filt_ppg(bp_chosen,flow,fhigh,fsamp);
% hist(corr(dmat',decimate(ts_out,375)),1000)

shreg=zeros(size(dmat));%empty matrix to fill shifted regressors
%shift the phys

for zz=1:(dimm(1)*dimm(2)*dimm(3))
   zz=23510;

indshift=int16(lmat(zz)*fsamp);% index needs to be shifted
shifted=brk_shift_zeropad(ts_out,indshift);

Y=detrend(dmat(zz,:)',4);
Y=tcs_filt(zz,:)';X=decimate(shifted,fsamp*0.75);
[B,BINT,R] = regress(Y,X);