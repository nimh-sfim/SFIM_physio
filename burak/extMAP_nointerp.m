%not working yet
%grep time from .acq file & do slidcorr
%little better
clear
addpath(genpath('/bin/NIfTI_20140122'))
addpath(genpath('~/bin/load_acq'))
addpath(genpath('~/bin/burak/'))
fileList = dir(fullfile(pwd, '*_pulse*.csv'));
c=readtable(fileList.name);

fileList = dir(fullfile(pwd, '*HoldC*.acq'));%Rest


myacq=load_acq(fileList.name);

%fetching time stamp from the file name
tm=strsplit(fileList.name,'T');
tn=strsplit(cell2mat(tm(2)),'.acq');
to=strsplit(cell2mat(tn(1)),'_');%this is the time stamp
time_stamp=datestr(hours(str2num(cell2mat(to(1))))+minutes(str2num(cell2mat(to(2))))+seconds(str2num(cell2mat(to(3)))),'HH:MM:SS');



% nvols=get_nvols('_bold_single_echo_750ms_20221117141247_24.nii');%Rest
nvols=get_nvols('_Resting_State_20221117141247_26.nii');%inhold


tdiff=10;%10min search_win
% scan_time=nvols*0.75;%sec
scan_time=440;%sec
caretaker=c(:,2).Time+datetime('00:00:00');
caretaker.Format='HH:mm:ss';
% datestr(seconds(scan_time),'HH:MM:SS')

dt = datetime( time_stamp, 'InputFormat', 'HH:mm:ss' );
dt.Format = 'HH:mm:ss';

bp_chosen=myacq.data(1:(scan_time)*500,2);%sampling 500
bp_match=interp1(linspace(0,1,length(bp_chosen)),bp_chosen,linspace(0,1,length(bp_chosen)/16));
ind=0;
step=1;
clear cval

tstart=dt - minutes(tdiff);
[aa,bb]=min(abs(caretaker-tstart));
ct_chosen=table2array(c(1:end,3));%sampling 31.25

for xx=1:(length(ct_chosen)-length(bp_match))
    cval(xx)=corr(ct_chosen((0+xx):(xx-1+length(bp_match))),bp_match');
end
[hh,jj]=max(cval);
ct_match=table2array(c((1+jj-1):(1+jj-2+length(bp_match)),3));
plot(cval)
% bb+jj-1 %caretaker scan start
disp('caretaker scan start is:')
caretaker(1+jj-1)
clf
plot(demean(ct_match)/std(ct_match))
hold on
plot(demean(bp_match)/std(bp_match))

hold on
resp_match=interp1(linspace(0,1,length(bp_chosen)),myacq.data(1:(scan_time)*500,1),linspace(0,1,length(bp_chosen)/16));
plot(demean(resp_match)/std(resp_match))
