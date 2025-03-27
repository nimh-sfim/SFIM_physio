clear;
basepath='/Users/akinb2/Desktop/allbp/'
sub=[10 12 13 14 15 16 18 19 20 21];
respmat=zeros([10 18750]);
bpmat=zeros([10 18750]);
ebpmat=zeros([10 18750]);
ctmat=zeros([10 18750]);
ectmat=zeros([10 18750]);
for xx=1:10
    fpath=strcat(basepath,'bp',num2str(sub(xx)),"/BoutHold_phys.mat");
load(fpath);
    vpath=strcat(basepath,'bp',num2str(sub(xx)),"/vitals.mat");
load(vpath);
respmat(xx,:)=normalize(resp_match(1:18750));
bpmat(xx,:)=normalize(bp_match(1:18750));
[yupper,ylower]=envelope(bp_match,100,'peak');
ebpmat(xx,:)=normalize(yupper(1:18750));
ctmat(xx,:)=normalize(ct_match(1:18750));
mapoutmat(xx,:)=mapout_fmri;
mapinmat(xx,:)=mapin_fmri;
% maprestmat(xx,:)=maprest_fmri;
end
