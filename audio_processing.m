% Load the recorded voice
[voice, fs] = audioread('voice.wav');

% Convert to mono if necessary
if size(voice, 2) > 1
    voice = mean(voice, 2);
end

% Create a time vector
t = (0:length(voice)-1)' / fs;

% Generate a 23000 Hz noise tone
noise = 0.1 * sin(2*pi*23000*t);

% Add noise to the voice
noisy_voice = voice + noise;

% Save the noisy recording
audiowrite('noisy_voice.wav', noisy_voice, fs);

% Play the noisy recording
sound(noisy_voice, fs);

% Design a numerically stable 20th-order Butterworth filter
[z, p, k] = butter(20, 22000/(fs/2), 'low');

% Convert to second-order sections
[sos, g] = zp2sos(z, p, k);

% Apply the filter
filtered_voice = g * sosfilt(sos, noisy_voice);

% Save the filtered recording
audiowrite('filtered_voice.wav', filtered_voice, fs);

% Plot before and after filtering
figure;

subplot(2,1,1);
plot(noisy_voice);
title('Before Filtering');
grid on;

subplot(2,1,2);
plot(filtered_voice);
title('After Filtering');
grid on;

% Calculate the DFT before and after filtering
N = length(noisy_voice);

before_dft = abs(fft(noisy_voice)) / N;
after_dft = abs(fft(filtered_voice)) / N;

% Frequency axis
f = (0:floor(N/2)) * fs / N;

% Keep positive frequencies
before_dft = before_dft(1:length(f));
after_dft = after_dft(1:length(f));

% Plot DFT comparison
figure;

subplot(2,1,1);
plot(f, 20*log10(before_dft + eps));
title('DFT Before Filtering');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

subplot(2,1,2);
plot(f, 20*log10(after_dft + eps));
title('DFT After Filtering');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

% Find the DFT bin closest to 23000 Hz
[~, idx] = min(abs(f - 23000));

% Calculate attenuation at that frequency
attenuation_db = 20 * log10( ...
    (before_dft(idx) + eps) / (after_dft(idx) + eps));

% Display the result
fprintf('Noise reduction at 23000 Hz: %.2f dB\n', attenuation_db);