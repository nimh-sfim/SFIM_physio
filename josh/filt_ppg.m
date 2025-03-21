function [perc_outliers, ts_out, ts_clean]=filt_ppg(timeseries,flow,fhigh,fsamp)

%typical flow=0.01 fhigh=0.1Hz
%inital filtering will be highpass with 0.01Hz
Wn=flow/(fsamp/2); N=2;
[B,A] = butter(N,Wn,'high');
% ts_detrend=filter(B,A,timeseries);%this removes mean and detrends
ts_detrend=filtfilt(B,A,timeseries);%this removes mean and detrends

%median adjustment to mitigate offset caused by outliers
ts_adjust=ts_detrend-(median(ts_detrend));

%anything above/below 2std deviation is equal to |2std|
stdlev=std(ts_adjust);
ts_clean=ts_adjust;
ts_clean(ts_clean>(2*stdlev))=(2*stdlev);
ts_clean(ts_clean<(-2*stdlev))=(-2*stdlev);
%testing
% ts_clean(ts_clean>(2*stdlev))=0;
% ts_clean(ts_clean<(-2*stdlev))=0;

%count censoring
outlier_indices = find(ts_adjust > (2*stdlev) | ts_adjust < (-2*stdlev)); %Find the indices of values outside the bounds
num_outliers = length(outlier_indices);    %Count the number of outliers
perc_outliers = num_outliers / length(ts_clean);

%atm, not sure if this is only considering times during scan or the whole
%length of the phys trace... Check... 


%%
% %decimate  factor of 10 --> 50samples if fsamp is 500...
% ts_filtdec=decimate(ts_filt,10);
% this step is probably not needed

% now do actual filtering low pass
Wlo=fhigh/(fsamp/2);%
[B2,A2]=butter(N,Wlo,'low');
% ts_out=filter(B2,A2,ts_clean);
ts_out=filtfilt(B2,A2,ts_clean);

% optional plotting check if outliers removed
% plot(ts_adjust);hold on; plot(ts_clean);legend('orig','clean')

% optional plotting check if spectrum is correct
% function is under /data/SFIM/akin/bin/burak/features/fftofvoxtc.m
% [freq1,spec1]=fftofvoxtc(ts_adjust,fsamp,1e5);%10000 is number of FFT points
% plot(freq1,spec1); hold on
% [freq2,spec2]=fftofvoxtc(ts_out,fsamp,1e5);
% plot(freq2,spec2)
% xlim([0 5]);legend('orig','filtered')

