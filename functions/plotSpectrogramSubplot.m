function plotSpectrogramSubplot(S_dB, prf, T, subplot_idx, total_plots, titleStr, clim_vals)
% plotSpectrogramSubplot - Plots a spectrogram in a specified subplot.
%
% Inputs:
%   S_dB        : Spectrogram magnitude in dB
%   F           : Frequency axis (Hz)
%   T           : Time axis (s)
%   subplot_idx : Index for the subplot position (e.g., 1, 2, or 3)
%   total_plots : Total number of subplots in the figure (e.g., 3)
%   titleStr    : Title string for the subplot
%   clim_vals   : [min max] color axis limits (dB)
%
% Example:
%   plotSpectrogramSubplot(S_dB, F, T, 1, 3, 'Spectrogram: Raw RP', [-80 0]);

    subplot(1, total_plots, subplot_idx);
    imagesc(T,[-prf/2 prf/2], S_dB);
    axis([0 max(T) -prf/3 prf/3])
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(titleStr);
    colorbar;
    colormap jet;
    caxis(clim_vals);
end
