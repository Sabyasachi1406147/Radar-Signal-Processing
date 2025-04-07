function [S_dB, F, T] = generateSpectrogramFromRP(RP_mat, fs_slow)
% generateSpectrogramFromRP - Compute spectrogram from a range profile matrix
%
% This function selects a representative slow-time signal from the input
% range profile matrix by taking the median range bin, then computes its
% spectrogram using a custom STFT implementation.
%
% Inputs:
%   RP_mat  : 2D matrix of range profile data [range bins x slow time]
%   fs_slow : Slow time sampling frequency (Hz) = 1/PRI
%
% Outputs:
%   S_dB    : Spectrogram magnitude in dB (normalized)
%   F       : Frequency axis (Hz)
%   T       : Time axis (s)
%
% Example:
%   [S_dB, F, T] = generateSpectrogramFromRP(RP, 1/PRI);

% Select the median range bin (representative slow-time signal)
selectedIdx = round(size(RP_mat, 1) / 2);
signal = RP_mat(selectedIdx, :);
% signal = sum(RP_mat, 1);

% Define STFT parameters
window_length = 256;        % Number of samples per window
nfft = 256;                 % Number of FFT points
shift = 16; % Sliding window shift (50% overlap)

% Determine the number of segments (frames)
N = floor((length(signal) - window_length) / shift);
out1 = zeros(nfft, N);

% Create a Hann window (column vector)
w = hann(window_length);

% Custom STFT: slide the window along the signal and compute FFT for each segment
for i = 1:N
    idx_start = (i-1)*shift + 1;
    idx_end = idx_start + window_length - 1;
    segment = signal(idx_start:idx_end);
    segment_windowed = segment(:) .* w;  % Apply Hann window
    tmp = fft(segment_windowed, nfft);
    out1(:, i) = tmp;
end
out2 = abs(flipud(fftshift(out1,1)));

% Create the frequency axis (Hz)
F = (0:nfft-1).' * (fs_slow / nfft);

% Create the time axis (s) using the center of each window
T = ((window_length/2) + (0:N-1)*shift) / fs_slow;

% Normalize the spectrogram and convert to dB scale
S_dB = 20 * log10(abs(out2) / max(abs(out2(:))) + eps);

end

