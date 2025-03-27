

sig2=normalize(shiftedlfo');
sig1=normalize(detrend(samplegm',4));
%% Step 1: Wavelet Decomposition to Identify Unwanted Components
waveletType = 'db4';  
decompositionLevel = 5;  

% Perform wavelet decomposition on the observed signal
[C, L] = wavedec(sig1, decompositionLevel, waveletType);

% Extract approximation coefficients (low-frequency trend)
approximation = appcoef(C, L, waveletType, decompositionLevel);

% Extract details (high-frequency components)
details = cell(1, decompositionLevel);
for i = 1:decompositionLevel
    details{i} = detcoef(C, L, i);
end

% Keep only the low-frequency component to remove high-frequency noise
C_filtered = zeros(size(C));
C_filtered(1:length(approximation)) = approximation; % Keep only approximation
sig_wavelet_filtered = waverec(C_filtered, L, waveletType);

%% Step 2: Kalman Filtering for Adaptive Unwanted Signal Removal
x_est = 0;  % Initial state estimate
P = 1;      % Initial estimation error covariance
Q = 1e-3;   % Process noise covariance (controls smoothness)
R = 0.1;    % Measurement noise covariance

A = 1;  % State transition model
H = 1;  % Observation model

x_filtered = zeros(1, N); % Store estimated unwanted signal

for k = 1:N
    % Prediction Step
    x_pred = A * x_est;
    P_pred = A * P * A' + Q;

    % Kalman Gain Calculation
    K = P_pred * H' / (H * P_pred * H' + R);

    % Update Step
    x_est = x_pred + K * (sig2(k) - H * x_pred);
    P = (1 - K * H) * P_pred;

    % Store estimated unwanted signal
    x_filtered(k) = x_est;
end

% Remove estimated unwanted signal from observed signal
sig_cleaned = sig1 - x_filtered;

%% Plot Results
clf
subplot(4,1,1);
plot(t, sig1, 'k', 'LineWidth', 1.2); hold on;
plot(t, sig2, 'r--', 'LineWidth', 1.2);
legend('Observed Signal (sig1)', 'Unwanted Signal (sig2)');
title('Observed Signal with Unwanted Component');

subplot(4,1,2);
plot(t, sig_wavelet_filtered, 'b', 'LineWidth', 1.2);
legend('Wavelet-Filtered Signal');
title('Wavelet Regression Output');

subplot(4,1,3);
plot(t, x_filtered, 'm', 'LineWidth', 1.2);
legend('Estimated Unwanted Signal (Kalman Filter)');
title('Kalman Filter Estimated Signal to Remove');

subplot(4,1,4);
plot(t, sig_cleaned, 'g', 'LineWidth', 1.2);
hold on; 
plot(t,sig1,'k', 'LineWidth', 1.2)
legend('Final Cleaned Signal','Observed Signal(sig1)');
title('Result After Wavelet & Kalman Filtering');
xlabel('Time');

disp('Signal processing complete: Unwanted signal removed.');