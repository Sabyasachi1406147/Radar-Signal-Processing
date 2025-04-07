function [S_dB, f, t] = generateCWTFromSignal(RP_mat, fs)
% generateCWTFromSignal - Compute a CWT spectrogram from a 1D signal.
%
% This function uses MATLAB’s Continuous Wavelet Transform (CWT) with the
% "amor" (Morlet) wavelet to generate a time-frequency representation.
%
% Inputs:
%   signal : 1D vector representing the signal (e.g., a range profile over slow time)
%   fs     : Sampling frequency of the signal (Hz)
%
% Outputs:
%   S_dB   : Spectrogram magnitude in dB (normalized)
%   f      : Frequency axis (Hz) corresponding to the wavelet scales
%   t      : Time axis (s)
%
% Example:
%   [S_dB, f, t] = generateCWTFromSignal(RP_mti_1D, fs_slow);

    % Compute the CWT using the 'amor' (Morlet) wavelet.
    selectedIdx = round(size(RP_mat, 1) / 2);
    signal = RP_mat(selectedIdx, :);
    fb = cwtfilterbank(SignalLength=length(signal),SamplingFrequency=fs,...
    FrequencyLimits=[0 500]);
    freqz(fb)
    [cfs, f] = cwt(signal, FilterBank=fb);

    if ndims(cfs) == 3 && size(cfs, 3) == 2
        % Combine the two channels into a single complex array.
        cfs = cfs(:,:,1) + 1i * cfs(:,:,2);
    end
    
    % Create the time axis based on the length of the signal.
    t = (0:length(signal)-1) / fs;
    
    % Calculate the magnitude and normalize to the maximum value.
    S = abs(cfs);
    S_dB = 20 * log10(S / max(S(:)) + eps);
end
