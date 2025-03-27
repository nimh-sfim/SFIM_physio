
% Load or define given signals (Replace with actual data)
% sig1 = load('sig1.mat'); % Observed signal
% sig2 = load('sig2.mat'); % Unwanted signal

N = length(sig1); % Ensure both signals have the same length
t = linspace(0, 600, N); % Assuming a time vector for visualization

% Parameters for Moving Window Regression
window_size = 26; % Size of the moving window (adjust as needed)
half_window = floor(window_size / 2);
beta_estimates = zeros(1, N); % Store regression coefficients

% Create a Hann (tapered) window for weighted regression
hann_window = hann(window_size); % Generates a symmetric Hann window

% Perform Moving Window Linear Regression with Tapered Weights
for k = 1:N
    % Define window boundaries
    start_idx = max(1, k - half_window);
    end_idx = min(N, k + half_window-1);
    
    % Extract data within the window
    x_window = sig2(start_idx:end_idx); % Unwanted signal
    y_window = sig1(start_idx:end_idx); % Observed signal

    % Adjust the Hann window size to match the actual number of points
    taper_window = hann_window(1:length(x_window)); 

    % Perform weighted linear regression: y = beta * x
    X = [x_window(:) ones(length(x_window), 1)]; % Add intercept
    W = diag(taper_window); % Create diagonal weight matrix

    % Solve weighted least squares: (X'WX)beta = X'Wy
    beta = (X' * W * X) \ (X' * W * y_window(:)); 

    % Store estimated coefficient for current point
    beta_estimates(k) = beta(1);
end

% Compute the estimated unwanted signal
sig2_estimated = beta_estimates .* sig2;

% Remove estimated unwanted signal
sig_cleaned = sig1 - sig2_estimated;

%% Plot Results

clf;
subplot(4,1,1);
plot(t, sig1, 'k', 'LineWidth', 1.2); hold on;
plot(t, sig2, 'r--', 'LineWidth', 1.2);
legend('Observed Signal (sig1)', 'Unwanted Signal (sig2)');
title('Observed Signal with Unwanted Component');

subplot(4,1,2);
plot(t, beta_estimates, 'b', 'LineWidth', 1.2);
legend('Moving Window Regression Coefficients (\beta)');
title('Estimated Regression Coefficients Over Time');

subplot(4,1,3);
plot(t, sig2_estimated, 'm', 'LineWidth', 1.2);
legend('Estimated Unwanted Signal (sig2 contribution)');
title('Estimated Signal to Remove');

subplot(4,1,4);
plot(t, sig_cleaned, 'g', 'LineWidth', 1.2);hold on;
plot(t,sig1,'k', 'LineWidth', 1.2)
legend('Final Cleaned Signal','Observed Signal(sig1)');
title('Result After Moving Window Regression with Tapering');
xlabel('Time');

disp('Moving window regression with tapered weights complete: Unwanted signal removed.');