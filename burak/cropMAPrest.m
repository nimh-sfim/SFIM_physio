%grep time from .acq file & do slidcorr
%to ext MAP from .csv caretaker recordings
clear
%dependencies
addpath(genpath('/Volumes/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/Volumes/SFIM/akin/bin/load_acq'))
addpath(genpath('/Volumes/SFIM/akin/bin/burak/'))

basepath='/Volumes/SFIM_physio/data/bp32/physio'
cd(basepath);

fileList = dir(fullfile(pwd, './Log*/Log*_pulse*.csv'));
c=readtable(strcat(fileList.folder,'/',fileList.name)); %load caretaker

fileList = dir(fullfile(pwd, '*Rest*.acq'));%Rest
myacq=load_acq(fileList.name); %load biopac

%fetching time stamp from the file name
tm=strsplit(fileList.name,'T');
tn=strsplit(cell2mat(tm(2)),'.acq');
to=strsplit(cell2mat(tn(1)),'_');%this is the time stamp
time_stamp=datestr(hours(str2num(cell2mat(to(1))))+minutes(str2num(cell2mat(to(2))))+seconds(str2num(cell2mat(to(3)))),'HH:MM:SS');



% nvols=get_nvols('_bold_single_echo_750ms_20221117141247_24.nii');%Rest
% nvols=get_nvols('rest.nii');%rest
nvols=1200;


tdiff=1;%10min search_win
 scan_time=nvols*0.75;%sec
% scan_time=440;%sec
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
scan_start=caretaker(1+jj-1);
clf
plot(demean(ct_match)/std(ct_match))
hold on
plot(demean(bp_match)/std(bp_match))

hold on
resp_match=interp1(linspace(0,1,length(bp_chosen)),myacq.data(1:(scan_time)*500,1),linspace(0,1,length(bp_chosen)/16));
plot(demean(resp_match)/std(resp_match))

% if above plots seems reasonable then following

scandur=duration(0,0,scan_time);
scan_stop=scan_start+scandur;
fileList = dir(fullfile(pwd, './Log*/Log*_vitals_*.csv'));
v=readtable(strcat(fileList.folder,'/',fileList.name));

tarray=table2array(v(:,2));

dump=datevec(scan_start-tarray);
vals=dump(:,4:6);
[aa,bb]=min(sum(vals'));
plot(sum(vals')) %-> check local minima
dump2=datevec(scan_stop-tarray);
vals2=dump2(:,4:6);
[aa2,bb2]=min(sum(vals2'));
plot(sum(vals2')) %-> check local minima
% bb2 must be greater than bb
tarray(bb) % ct time start
tarray(bb2) % ct time stop
% bb2=4227;
in_index=bb:bb2;

MAPrest=table2array(v(in_index,3));
% HRrest=table2array(v(in_index,4));
clf;plot(MAPrest)
save('MAPrest','MAPrest')

