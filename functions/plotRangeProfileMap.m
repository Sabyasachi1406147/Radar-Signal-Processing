function plotRangeProfileMap(RP, vRange, titleText, exclude_bins, subplot_idx, total_plots)
% plotRangeProfileMap - Plots the range profile map in dB scale
%
% Inputs:
%   RP          : Complex-valued range profile [range bins x chirps]
%   vRange      : Corresponding range values (meters)
%   titleText   : Title of the plot
%   exclude_bins: Number of initial bins to exclude (optional)
%   subplot_idx : Subplot index (e.g., 1, 2, 3 for left to right)
%   total_plots : Total number of subplots (e.g., 3)

if nargin < 4
    exclude_bins = 0;
end

if nargin >= 5
    subplot(1, total_plots, subplot_idx);  % Horizontal layout
else
    figure;
end

imagesc([0 size(RP,2)], vRange(exclude_bins+1:end), ...
    20*log10(abs(RP(exclude_bins+1:end,:))));
xlabel('Number of Chirps');
ylabel('Range (meters)');
title(titleText);
colorbar;
axis tight;
end
