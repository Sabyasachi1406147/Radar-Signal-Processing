function detection_mask = cacfar2D(data, T_range, T_doppler, G_range, G_doppler, alpha)
% cacfar2D - Apply 2D Cell-Averaging CFAR on a 2D radar map.
%
% Inputs:
%   data      : 2D matrix (e.g., range-Doppler map magnitudes) [range x doppler]
%   T_range   : Number of training cells on each side in the range dimension
%   T_doppler : Number of training cells on each side in the Doppler dimension
%   G_range   : Number of guard cells on each side in the range dimension
%   G_doppler : Number of guard cells on each side in the Doppler dimension
%   alpha     : Threshold multiplier (determines the desired false alarm rate)
%
% Outputs:
%   detection_mask : 2D binary mask of detections (same size as data)
%
% Example:
%   detection_mask = cacfar2D(RD_map_mti, 4, 4, 2, 2, 1.5);

[rows, cols] = size(data);
detection_mask = zeros(rows, cols);

% Total window size in each dimension
win_range = 2*T_range + 2*G_range + 1;
win_doppler = 2*T_doppler + 2*G_doppler + 1;

% Loop over cells that are not too close to the boundary
for i = (T_range+G_range+1):(rows - (T_range+G_range))
    for j = (T_doppler+G_doppler+1):(cols - (T_doppler+G_doppler))
        % Extract the window around the cell under test (CUT)
        window = data(i - (T_range+G_range) : i + (T_range+G_range), ...
                      j - (T_doppler+G_doppler) : j + (T_doppler+G_doppler));
        
        % Create a mask for training cells: ones for training cells, zeros for guard cells and CUT.
        training_mask = ones(size(window));
        training_mask(T_range+1:T_range+2*G_range+1, T_doppler+1:T_doppler+2*G_doppler+1) = 0;
        
        % Number of training cells
        num_training = sum(training_mask(:));
        
        % Sum and average noise level from training cells
        noise_sum = sum(window(training_mask==1));
        noise_avg = noise_sum / num_training;
        
        % Determine the threshold
        threshold = alpha * noise_avg;
        
        % The cell under test is at the center of the window
        CUT = data(i, j);
        if CUT > threshold
            detection_mask(i, j) = 1;
        end
    end
end
end
