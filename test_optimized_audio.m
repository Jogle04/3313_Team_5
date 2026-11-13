
clc;
clear;

% Load optimized filter parameters
load('optimized_filter.mat');

% Load noisy voice recording
[y, audioFs] = audioread('noisy_voice.wav');

if audioFs ~= fs
    y = resample(y, fs, audioFs);
end

% Reconstruct digital poles and residues
p = -exp(x(1:10)) + 1j*exp(x(11:20));
r = x(21:30) + 1j*x(31:40);

pd = exp([p; conj(p)]/fs);
rd = exp(x(41))*[r; conj(r)]/fs;

% Apply optimized IIR filter
filtered = zeros(size(y));

for k = 1:length(pd)
    filtered = filtered + ...
        filter(rd(k), [1, -pd(k)], y);
end

filtered = real(filtered);

% Save filtered audio
audiowrite('optimized_filtered_voice.wav', filtered, fs);

disp('Optimized filtered audio saved successfully.');
