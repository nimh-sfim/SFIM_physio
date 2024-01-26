
% https://www.mathworks.com/help/matlab/ref/fft.html

sbjid=["sub20"];      % sub13, sub15, sub16, sub17, sub18, sub20
task=["resting"];     % Baseline, Binhold, BinholdBroken, BoutHold, Resting
column=2;                   % 1 for resp, 4 for card
smoothing=1;             %Do you want to perform smoothing? If yes, 1. If not, 0. 

dir_input=strcat('/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/',sbjid,'/');
filename=strcat(sbjid, '_', task,'_physio');
filepath=strcat(dir_input,filename,'.tsv');
json_filepath=strcat(dir_input,filename,'.json');

dir_output=strcat('/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_results/',sbjid,'/');
hr_filename=strcat(sbjid, '_heart-rate');
hr_filepath=strcat(dir_output,hr_filename,'.tsv');

data = load(hr_filepath);
json_info = readstruct(json_filepath);
start_time = json_info.StartTime * -1;      % Start times are negative
Fs = 50   %json_info.SamplingFrequency;           % Sampling frequency                    
L = length(data);                           % Length of signal
data = data(start_time*Fs+1:L,column);      % Cannot start at index 0, must be 1

cutoff_f = 1; 
data_mean = mean(data);
if smoothing==1
    data = data - data_mean;
    [b,a] = cheby2(4,40,cutoff_f/(Fs/2),'low'); %butter or cheby2? 
    freqz(b,a);
    dataOut = filtfilt(b,a,data);
    % data = data + data_mean;
    % dataOut = dataOut + data_mean;
end

figure(1); tiledlayout(4,2)
nexttile(1)
plot(dataOut);
hold on
plot(data);

nexttile(2)
plot(dataOut);
hold on
plot(data);

Y_1 = fft(data);
Y_2 = fft(dataOut);
T = 1/Fs;               % Sampling period       
t = (0:L-1)*T;          % Time vector

P2_1 = abs(Y_1/L);
P1_1 = P2_1(1:L/2+1);
P1_1(2:end-1) = 2*P1_1(2:end-1);

P2_2 = abs(Y_2/L);
P1_2 = P2_2(1:L/2+1);
P1_2(2:end-1) = 2*P1_2(2:end-1);

% Variability of heart rate should be 0.01 - 0.1 Hz 
% Variability for respiratory should be 0.2 to 0.3 Hz 

f = Fs/L*(0:(L/2));
nexttile(3)
plot(f,P1_1,"LineWidth",1); xlim([0.01,1]);
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

nexttile(4)
plot(f,P1_2,"LineWidth",1); xlim([0.01,1]);
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

nexttile(5)
plot(f,P1_1,"LineWidth",1); xlim([0.01,5]);

nexttile(6)
plot(f,P1_2,"LineWidth",1); xlim([0.01,5]);

nexttile(7)
plot(data); title("Heart Rate trace")

nexttile(8)
plot(dataOut); title("Heart Rate Filtered")


