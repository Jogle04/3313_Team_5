% CSE 3313 Digital Low-pass Filter Design - Team 5
% Impulse Invariance 
% IIR Least P-Norm

% Clear any previous signals
clear; 
clc; 
close all; 

% Key Specifications 
order = 20; % Filter order
fc = 22000; % Cutoff frequency
fs = 48000; % Sampling rate
passband = fc / (fs / 2); % Passband edge
stopband = 23500 / (fs/2); % Stopband edge
num_order = 10; % Numerator order
den_order = 10; % Denominator order

f_points = [0, passband, 23500 / (fs / 2), 1.0]; % Frequency points
f_edges = [0, passband, 23500 / (fs / 2), 1.0]; % Frequency edges
mag = [1,1,0,0]; % Magnitude
weights = [1,1,10,10]; 

[b,a] = iirlpnorm(num_order, den_order, f_points, f_edges, mag, weights); % Filter using least p-norm

[raw_audio, file_fs] = audioread('Recording.m4a'); % Recorded audio, put the audio file name here for testing

if file_fs ~= fs
    raw_audio = resample(raw_audio, fs, file_fs); % Force 48000 Hz audio adjustment
end

filtered_audio = filter(b, a, raw_audio); % Filter noisy audio

figure; 
freqz(b, a, 2048, fs); 
title('IIR least p-norm low-pass filter design');
grid on; % Enable grid

figure; 
subplot(2,1,1); 
plot(raw_audio, 'Color', '#FFA500'); % Plot raw audio in orange
title('Audio Before Filtering');
ylim([-1,1]); % -1 to 1 Y-axis
grid on; % Enable grid

subplot(2,1,2); 
plot(filtered_audio, 'Color', '#0000FF'); % Plot filtered audio in blue
title('Audio After Filtering');
ylim([-1,1]); % -1 to 1 Y-axis
grid on; % Enable grid

auido_length = length(raw_audio); % Plot length of audio file
height = linspace(0, fs / 2, floor(audio_length / 2) + 1);

raw_dft = abs(fft(raw_audio)); 
raw_dft = raw_dft(1: length(height)); 

filtered_dft = abs(fft(filtered_audio)); 
filtered_dft = filtered_dft(1: length(height)); 

figure; 
subplot(2,1,1);
plot(filtered, 20*log10(raw_dft + eps), 'Color' , '#FFA500');
title('DFT Before Filtering');
xlim([0 fs / 2]);
grid on;

subplot(2,1,2);
plot(height, 20*log10(filtered_dft + eps), 'Color', '#0000FF');
title('DFT After Filtering');
xlim([0 fs / 2]);
grid on;
