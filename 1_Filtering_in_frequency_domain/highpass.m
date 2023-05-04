clc;
clear all;
close all;

% Create a 2D highpass filter with cutoff frequency of 0.2
[f1, f2] = freqspace(256, 'meshgrid');
d = sqrt(f1.^2 + f2.^2);
h = double(d > 0.2);

% Compute the impulse response using the inverse 2D FFT
impulse = ifft2(ifftshift(h));

% Plot the impulse response
figure;
surf(impulse);
title('Impulse Response of 2D Highpass Filter');
xlabel('X');
ylabel('Y');
zlabel('Amplitude');
