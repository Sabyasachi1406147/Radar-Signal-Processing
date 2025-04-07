function detection_mask = cacfar1D(signal, numTraining, numGuard, alpha)
% cacfar1D - Apply 1D Cell-Averaging CFAR to a 1D signal.
%
% Inputs:
%   signal     : 1D vector (e.g., range profile)
%   numTraining: Number of training cells on each side of the cell under test.
%   numGuard   : Number of guard cells on each side.
%   alpha      : Threshold multiplier (to set the desired false alarm rate).
%
% Outputs:
%   detection_mask : 1D binary vector indicating detections (1 for detection, 0 otherwise).
%
% Example:
%   detection_mask = cacfar1D(signal, 4, 2, 1.5);

N = length(signal);
detection_mask = zeros(N, 1);

for i = (numTraining + numGuard + 1):(N - numTraining - numGuard)
    % Training cells from left and right of the CUT (cell under test)
    training_cells = [signal(i - numTraining - numGuard : i - numGuard - 1); ...
                      signal(i + numGuard + 1 : i + numGuard + numTraining)];
    noise_est = mean(training_cells);
    threshold = alpha * noise_est;
    
    if signal(i) > threshold
        detection_mask(i) = 1;
    end
end

end
