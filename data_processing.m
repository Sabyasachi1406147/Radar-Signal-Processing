clc;
clear all;
close all;

%% Create/verify output folder
outputFolder = 'results';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Add Path to Functions Folder
addpath('C:\Users\sb3682.ECE-2V7QHQ3\My Stuff\Radar-Signal-Processing\FMCW-Radar_for-HAR\functions');

%% Load Data
load('class_01_Ali_1.mat');  % Loads variable 'data_cut' [256 x 26052]

%% Radar Configuration
params.f_start   = 76e9;       % Start frequency (Hz)
params.f_stop    = 80e9;       % Stop frequency (Hz)
params.SweepTime = 40e-3;      % Sweep time (s)
params.NoC       = 128;        % Number of chirps per frame

%% Generate Full Range Profile
[RP, vRange] = generateRangeProfile(data_cut, params);

%% 1) DISPLAY RANGE PROFILES IN A FULL-SCREEN FIGURE
hFigRangeProfiles = figure('Name','Range Profiles – Before and After Processing',...
                           'NumberTitle','off',...
                           'Units','normalized','OuterPosition',[0 0 1 1]);  % Full screen
drawnow;   % Force MATLAB to size the figure

% Lock the full-screen size in pixels so subplots don't shift.
set(hFigRangeProfiles, 'Units','pixels');
posRP = get(hFigRangeProfiles,'Position');
set(hFigRangeProfiles, 'Resize','off','Position',posRP);

% Subplot 1: Raw full-range profile (using half the data for visualization)
plotRangeProfileMap(RP(2:end/2,:), vRange(2:end/2)/2, ...
    '1) Raw Range Profile (Full Range)', 0, 1, 3);

% --- Range Gating ---
RMin = 0.6;    % Minimum range (m)
RMax = 1.4;    % Maximum range (m)
[~, RMinIdx] = min(abs(vRange - RMin));
[~, RMaxIdx] = min(abs(vRange - RMax));
vRangeExt = vRange(RMinIdx:RMaxIdx);
RPExt = RP(RMinIdx:RMaxIdx, :);

% Subplot 2: After range gating
plotRangeProfileMap(RPExt, vRangeExt, ...
    '2) After Range Gating (0.6m–1.4m)', 0, 2, 3);

% --- DC Subtraction + IQ Balancing ---
RPExt_balanced = dcSubtraction(RPExt);
% Optionally, you can add IQ balancing here:
% [RPExt_balanced, ~, ~] = iqBalancing(RPExt);

% (Reuse subplot 2 or use a different subplot if you truly want them separate)
plotRangeProfileMap(RPExt_balanced, vRangeExt, ...
    '2) After DC Subtraction + IQ Balancing', 0, 2, 3);

% --- MTI Filtering ---
cutoff = 0.03;  % Normalized cutoff frequency
RPExt_mti = mtiFiltering(RPExt_balanced, cutoff);

% Subplot 3: Range Profile after MTI
plotRangeProfileMap(RPExt_mti, vRangeExt, ...
    '3) After DC Subtraction + IQ Balancing + MTI', 0, 3, 3);

%% SAVE the full-screen Range Profile figure
saveas(hFigRangeProfiles, fullfile(outputFolder, 'RangeProfiles.png'));
savefig(hFigRangeProfiles, fullfile(outputFolder, 'RangeProfiles.fig'));

%% 2) RANGE-DOPPLER MAPPING
fc    = (params.f_start + params.f_stop) / 2;   % Center frequency (Hz)
Tp    = params.SweepTime / params.NoC;          % Chirp duration (s)
PRI   = Tp;                                     % Pulse Repetition Interval (s)
PRF   = 1 / PRI;                                % Pulse Repetition Frequency (Hz)
slope = (params.f_stop - params.f_start) / Tp;  % Chirp slope (Hz/s)

% For Range-Doppler processing:
RMin = 0.7;            % Minimum range (m) for Doppler processing
RMax = 1.3;            % Maximum range (m) for Doppler processing
exclude_bins = 5;      % Exclude initial range bins
rd_window_size = 128;  % Doppler FFT window (# of chirps)
shift          = 74;   % Sliding window shift (# of chirps)
NFFTVel        = 256;  % Doppler FFT size

% Generate Range-Doppler Maps
[RD_map_raw, vVel_raw, vRange_raw] = generateRangeDopplerMap( ...
    RP, vRange, fc, Tp, PRI, slope, ...
    0, max(vRange), 0, ...
    rd_window_size, shift, NFFTVel);

[RD_map_proc, vVel_proc, vRange_proc] = generateRangeDopplerMap( ...
    RPExt_balanced, vRangeExt, fc, Tp, PRI, slope, ...
    RMin, RMax, exclude_bins, ...
    rd_window_size, shift, NFFTVel);

[RD_map_mti, vVel_mti, vRange_mti] = generateRangeDopplerMap( ...
    RPExt_mti, vRangeExt, fc, Tp, PRI, slope, ...
    RMin, RMax, exclude_bins, ...
    rd_window_size, shift, NFFTVel);

%% Display & Save Range-Doppler Video (Full-screen handled inside displayRDMVideo)
displayRDMVideo(RD_map_raw,  vVel_raw,  vRange_raw, ...
                RD_map_proc, vVel_proc, vRange_proc, ...
                RD_map_mti,  vVel_mti,  vRange_mti, ...
                outputFolder);

%% 3) SPECTROGRAM GENERATION
[S_raw_dB,  F_raw,  T_raw]   = generateSpectrogramFromRP(RP, PRF);
[S_proc_dB, F_proc, T_proc]  = generateSpectrogramFromRP(RPExt_balanced, PRF);
[S_mti_dB,  F_mti,  T_mti]   = generateSpectrogramFromRP(RPExt_mti, PRF);

%% DISPLAY SPECTROGRAMS IN A FULL-SCREEN FIGURE
hFigSpectrograms = figure('Name','Spectrogram Comparison','NumberTitle','off',...
                          'Units','normalized','OuterPosition',[0 0 1 1]); 
drawnow;
set(hFigSpectrograms, 'Units','pixels');
posSpec = get(hFigSpectrograms,'Position');
set(hFigSpectrograms, 'Resize','off','Position',posSpec);

clim_vals = [-60 0];

% Subplot 1: Raw
plotSpectrogramSubplot(S_raw_dB, PRF, T_raw, 1, 3, 'Spectrogram: Raw RP', clim_vals);

% Subplot 2: Processed
plotSpectrogramSubplot(S_proc_dB, PRF, T_proc, 2, 3, 'Spectrogram: Processed', clim_vals);

% Subplot 3: Processed + MTI
plotSpectrogramSubplot(S_mti_dB, PRF, T_mti, 3, 3, 'Spectrogram: Processed+MTI', clim_vals);

sgtitle('Spectrogram Comparison for Different Processing Stages');

%% SAVE the full-screen Spectrogram figure
saveas(hFigSpectrograms, fullfile(outputFolder, 'SpectrogramComparison.png'));
savefig(hFigSpectrograms, fullfile(outputFolder, 'SpectrogramComparison.fig'));
