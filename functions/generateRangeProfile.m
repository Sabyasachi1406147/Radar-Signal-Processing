% -------------------------------------------------------------------------
function [RP, vRange] = generateRangeProfile(data_cut, params)
% generateRangeProfile - Generate a range profile from radar data.
%
%   [RP, vRange] = generateRangeProfile(data_cut, params)
%
%   Inputs:
%       data_cut - Matrix of raw radar data with dimensions:
%                  [fast time samples x slow time samples]
%       params   - Structure containing radar parameters:
%                  params.f_start    : Starting frequency (Hz)
%                  params.f_stop     : Stopping frequency (Hz)
%                  params.SweepTime  : Time for one frame (s)
%                  params.NoC        : Number of chirps per frame
%
%   Outputs:
%       RP     - Computed range profile (FFT output after windowing)
%       vRange - Vector of range values (meters) corresponding to FFT bins

% Extract parameters
f_start   = params.f_start;
f_stop    = params.f_stop;
SweepTime = params.SweepTime;
NoC       = params.NoC;

% Radar parameters and derived quantities
PRI = SweepTime / NoC;   % Pulse Repetition Interval (s)
c0 = 299792458;          % Speed of light (m/s)
N = size(data_cut, 1);   % Number of ADC samples per chirp
fs = N / PRI;            % Actual sampling frequency (Hz)

% Calculate chirp parameters
slope = (f_stop - f_start) / PRI;
B = f_stop - f_start;    % Bandwidth

num_of_chirps = size(data_cut, 2);

% Windowing: Use a Hanning window for the fast time samples (exclude the first sample)
Win2D = hanning(N-1); 
Win2D = repmat(Win2D, 1, num_of_chirps);
ScaWin = sum(Win2D(:,1));  % Scaling factor to compensate for windowing

% FFT parameters
NFFT = 2^10;  % Number of FFT points for fast time

% Compute the range vector (vRange) in meters
vRange = ([0:NFFT-1].' / NFFT) * fs * c0 / (2 * slope);

% Perform FFT along the fast time dimension (from 2nd sample to end, after windowing)
RP = fft(data_cut(2:end, :) .* Win2D, NFFT, 1) / ScaWin;
end
