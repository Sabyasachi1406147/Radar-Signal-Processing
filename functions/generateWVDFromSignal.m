function [W, t, f] = generateWVDFromSignal(RP_mat, fs)
% generateWVDFromSignal - Compute the Wigner-Ville Distribution of a 1D signal.
%
% The Wigner-Ville Distribution (WVD) of a signal x(t) is defined as:
%   W_x(t, f) = \int_{-\infty}^{\infty} x(t+\tau/2) x^*(t-\tau/2) exp(-j2\pi f \tau) d\tau
%
% This function computes a discrete approximation of the WVD for the input signal.
%
% Inputs:
%   signal : 1D vector representing the signal (e.g., the aggregated range profile)
%   fs     : Sampling frequency (Hz) of the signal (slow time)
%
% Outputs:
%   W : Matrix containing the WVD (time x frequency)
%   t : Time axis (s)
%   f : Frequency axis (Hz)
%
% Example:
%   [W, t, f] = generateWVDFromSignal(RP_mti_1D, fs_slow);
selectedIdx = round(size(RP_mat, 1) / 2);
signal = RP_mat(selectedIdx, :);
N = length(signal);
W = zeros(N, N);
t = (0:N-1) / fs;

% Compute the WVD for each time index.
% Here we use an even lag approach so that indices remain integers.
for n = 1:N
    % Maximum lag to consider without going out-of-bounds
    L = min(n-1, N-n);
    if mod(L,2) ~= 0
        L = L - 1;
    end
    % For each even lag from -L to L
    for tau = -L:2:L
        idx1 = n + tau/2;
        idx2 = n - tau/2;
        % Compute the product x(t+tau/2)*conj(x(t-tau/2))
        W(n, tau + N/2 + 1) = signal(idx1) * conj(signal(idx2));
    end
    % Apply FFT along the lag dimension to convert to frequency domain.
    W(n, :) = fftshift(fft(W(n, :)));
end

% Create frequency axis spanning [-fs/2, fs/2]
f = linspace(-fs/2, fs/2, N);
% Since for analytic signals the WVD is (ideally) real, take the real part.
W = real(W);
end
