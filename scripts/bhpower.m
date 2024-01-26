function [pband,ptot,per_power] = bhpower(filepath, json_filepath, Fs,freqRange,column)
%BHPOWER
%   Calculates percentage of power in a specified frequency range, such as
%   that of a breath-hold task.
%   Reference: https://www.mathworks.com/help/signal/ref/bandpower.html

%%%%%%%%%%%
% Inputs:
%%%%%%%%%%
% filepath = full path to input signal
% Fs = sampling frequency, in Hz
% freqRange = frequency range of interest, e.g. [0.014,0.02]

%%%%%%%%%%%
% Outputs:
%%%%%%%%%%
% pband = power in frequency range of interest
% ptot = total power
% per_power = percentage of power in frequency range of interest

data = load(filepath);
json_info = readstruct(json_filepath);
start_time = json_info.StartTime * -1;      %start times are negative
data_samples = length(data);
data = data(start_time*Fs+1:data_samples,column);   %cannot start at index 0, must be 1
N = data_samples - (start_time*Fs); 

% figure(2); plot(data);

% Maximum freq for total power = Fs*(N-1)/(2*N), where N is number of samples
% in input signal
maxFreq = Fs*(N-1)/(2*N);

pband=bandpower(data,Fs,freqRange);
ptot=bandpower(data,Fs,[0,maxFreq]);
per_power=pband/ptot*100;

% figure(1)
% %pspectrum(data) %this is not the best way to visualize, but I'll start with this.
% [pxx,f] = pwelch(data, freqRange, 'power');     %'power'
% plot(f,10*log10(pxx))   
% xlabel('Frequency (Hz)')
% ylabel('PSD (dB/Hz)')

end

