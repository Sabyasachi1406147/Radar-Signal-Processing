function [RD_map, vVel, vRangeExt] = generateRangeDopplerMap(...
    RP, vRange, fc, Tp, PRI, slope, ...
    RMin, RMax, exclude_bins, ...
    rd_window_size, shift, NFFTVel)
% generateRangeDopplerMap - Computes a 3D Range-Doppler map over time windows
%
% This function first performs range gating on the input range profile RP,
% then computes the Doppler (FFT) on the slow-time dimension over sliding windows.
%
% Inputs:
%   RP             : Range profile [range bins x chirps]
%   vRange         : Range axis (meters)
%   fc             : Center frequency (Hz)
%   Tp             : Chirp duration (s)
%   PRI            : Pulse Repetition Interval (s)
%   slope          : Chirp slope (Hz/s)
%   RMin, RMax     : Range gating bounds (m)
%   exclude_bins   : Number of initial range bins to discard (optional)
%   rd_window_size : Doppler FFT window size (number of chirps)
%   shift          : Step size for moving window (chirps)
%   NFFTVel        : Number of FFT points for Doppler processing
%
% Outputs:
%   RD_map    : 3D Range-Doppler map [gated range bins x doppler bins x time window]
%   vVel      : Velocity axis (m/s)
%   vRangeExt : Gated (and optionally truncated) range axis (m)
%
% Note: This version does not perform DC subtraction or IQ balancing;
%       it assumes the input RP has already been preprocessed.

% -------------------------
% Step 1: Range Gating
% -------------------------
[~, RMinIdx] = min(abs(vRange - RMin));
[~, RMaxIdx] = min(abs(vRange - RMax));
vRangeExt = vRange(RMinIdx:RMaxIdx);
RPExt = RP(RMinIdx:RMaxIdx, :);

% Optionally discard the first 'exclude_bins' (e.g., for clutter removal)
if exclude_bins > 0
    vRangeExt = vRangeExt(exclude_bins+1:end);
    RPExt = RPExt(exclude_bins+1:end, :);
end

% -------------------------
% Step 2: Doppler Processing
% -------------------------
WinVel = hanning(rd_window_size).';   % Create a row vector Hann window
ScaWinVel = sum(WinVel);               % Scaling factor
WinVel2D = repmat(WinVel, size(RPExt, 1), 1);  % Replicate for each range bin

% Compute velocity axis:
vFreqVel = (-NFFTVel/2:NFFTVel/2-1).' / NFFTVel * (1 / Tp);
vVel = vFreqVel * 3e8 / (2 * fc);

% Setup sliding window along slow time
num_chirps = size(RPExt, 2);
N_meas = floor((num_chirps - rd_window_size) / shift);
RD_map = zeros(size(RPExt, 1), NFFTVel, N_meas);

% -------------------------
% Step 3: Range-Doppler Mapping
% -------------------------
for i = 1:N_meas
    idx_start = (i-1)*shift + 1;
    idx_end = idx_start + rd_window_size - 1;
    RP_segment = RPExt(:, idx_start:idx_end);
    RD = fftshift(fft(RP_segment .* WinVel2D, NFFTVel, 2) / ScaWinVel, 2);
    RD_map(:,:,i) = abs(RD); % Store magnitude only
end

end
