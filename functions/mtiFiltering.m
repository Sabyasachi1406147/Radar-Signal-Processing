function RPExt_mti = mtiFiltering(RPExt, cutoff)
% mtiFiltering - Apply MTI filtering to remove stationary clutter.
%
% This function applies a 1st-order highpass Butterworth filter along the slow-time
% dimension for each range bin in the input matrix.
%
% Inputs:
%   RPExt  : Range profile matrix [range bins x slow time/chirps]
%   cutoff : Normalized cutoff frequency (0-1) (e.g., 0.03)
%
% Outputs:
%   RPExt_mti : MTI-filtered range profile matrix.
%
% Example:
%   RPExt_mti = mtiFiltering(RPExt_balanced, 0.03);

    [b, a] = butter(1, cutoff, 'high');  % 1st order highpass filter
    [m, n] = size(RPExt);
    RPExt_mti = zeros(m, n);
    for k = 1:m
        RPExt_mti(k,:) = filter(b, a, RPExt(k,:));
    end
end
