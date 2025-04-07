function [RPExt_balanced, d_ampImb, phi] = iqBalancing(RPExt)
% iqBalancing - Performs IQ imbalance correction on complex radar data
%
% Inputs:
%   RPExt - Complex-valued range profile data [range bins x chirps]
%
% Outputs:
%   RPExt_balanced - IQ-balanced output
%   d_ampImb       - Estimated amplitude imbalance
%   phi            - Estimated phase imbalance

% Mean values (to remove DC offsets)
miux = mean(real(RPExt), 2);
miuy = mean(imag(RPExt), 2);

% Power statistics
I2_bar = mean((real(RPExt) - miux).^2, 2);           % Variance of I
Q2_bar = mean((imag(RPExt) - miuy).^2, 2);           % Variance of Q
IQ_bar = mean((real(RPExt) - miux) .* (imag(RPExt) - miuy), 2);  % Covariance

% Imbalance parameters
D_bar = IQ_bar ./ I2_bar;
C_bar = sqrt(Q2_bar ./ I2_bar - D_bar.^2);

% Amplitude and phase imbalance
d_ampImb = sqrt(C_bar.^2 + D_bar.^2) - 1;
phi = atan(D_bar ./ C_bar);  % Phase imbalance in radians

% IQ correction
I_rawdata = real(RPExt) - miux;
Q_rawdata = ((imag(RPExt) - miuy) ./ (1 + d_ampImb) - I_rawdata .* sin(phi)) ./ cos(phi);

% Construct balanced complex signal
RPExt_balanced = I_rawdata + 1i * Q_rawdata;

end
