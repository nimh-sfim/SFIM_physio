clf;
%this code gets the low freq part of the pulse.
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/load_acq'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))
fileList.folder = '/vf/users/SFIM_physio/data/bp32/physio/';
fileList = dir(fullfile(fileList.folder, '*DanielResting*.acq'));%Rest
myacq=load_acq(fullfile(fileList.folder,fileList.name)); %load biopac
uf_puls=myacq.data(:,2);
fsamp=500;
seg=uf_puls(1:15000);

% [b,a] = cheby2(4,40,[0.008 40]/fsamp,'bandpass');
% tcs_filt = filtfilt(b,a,seg');



Fn = fsamp/2;                                           % Nyquist Frequency (Hz)
Wp = 0.01/Fn;                                           % Passband Frequency (Normalised)
Ws = 0.1/Fn;                                           % Stopband Frequency (Normalised)
Rp =   1;                                               % Passband Ripple (dB)
Rs =  30;                                               % Stopband Ripple (dB)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                       
[z,p,k] = ellip(n,Rp,Rs,Wp,'bandpass');                      
[soslp,glp] = zp2sos(z,p,k);                           
figure(5)
% freqz(soslp, 2^16, Fs)                                  % Filter Bode Plot
%filtfilt for symetrical filter 
filt_seg = filtfilt(soslp,glp,seg);      
plot(linspace(1,30,15000),seg,'LineWidth',2);
hold on
plot(linspace(1,30,15000),filt_seg,'LineWidth',2);
