function data_out = dcSubtraction(data_in)
% dcSubtraction - Removes DC/static component from each range bin.
%
% Inputs:
%   data_in  : [range bins x chirps] input data
% Output:
%   data_out : DC-subtracted data

% Compute mean across chirps (slow time)
meanDC = mean(data_in, 2);  % mean for each range bin

% Subtract mean (broadcast across chirps)
data_out = data_in - repmat(meanDC, 1, size(data_in, 2));
end
