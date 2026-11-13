
clc;
clear;

fs = 48000;
fc = 22000;
fstop = 23500;
order = 20;

% Initialize analog filter poles
[~, p0, ~] = butter(order, 2*pi*fc, 's');
p0 = p0(imag(p0) > 0);
p0 = p0(:);

% Initialize optimization variables
x0 = [log(-real(p0)); ...
      log(imag(p0)); ...
      zeros(10,1); ...
      zeros(10,1); ...
      0];

% Frequency grid
f = linspace(0, fs/2, 1200);
pass = f <= fc;
stop = f >= fstop;
omega = 2*pi*f/fs;

% Optimize impulse-invariant IIR filter
objective = @(x) response_error(x, omega, pass, stop, fs);
constraints = @(x) filter_constraints(x, omega, pass, stop, fs);

options = optimoptions('fmincon', ...
    'Display', 'off', ...
    'Algorithm', 'sqp', ...
    'MaxIterations', 300, ...
    'MaxFunctionEvaluations', 30000);

x = fmincon(objective, x0, [], [], [], [], [], [], ...
    constraints, options);

% Save optimized filter parameters
save('optimized_filter.mat', 'x', 'fs', 'fc', 'fstop', 'order');

% Evaluate filter performance
H = impulse_response(x, omega, fs);

pass_db = 20*log10(abs(H(pass)) + eps);
stop_db = 20*log10(abs(H(stop)) + eps);

ripple = max(pass_db) - min(pass_db);
attenuation = -max(stop_db);

poles = -exp(x(1:10)) + 1j*exp(x(11:20));
digital_poles = exp([poles; conj(poles)]/fs);

fprintf('Passband ripple: %.4f dB\n', ripple);
fprintf('Stopband attenuation: %.4f dB\n', attenuation);
fprintf('Maximum pole magnitude: %.6f\n', ...
    max(abs(digital_poles)));

% Plot frequency response
figure;
plot(f, 20*log10(abs(H) + eps));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Optimized Impulse-Invariant IIR Filter');
grid on;

% Least-p-norm objective function
function E = response_error(x, w, pass, stop, fs)
    H = impulse_response(x, w, fs);
    magnitude = abs(H);

    e1 = magnitude(pass) - 1;
    e2 = magnitude(stop);

    E = mean(abs(e1).^8) + 10*mean(abs(e2).^8);
end

% Impulse-invariant frequency response
function H = impulse_response(x, w, fs)
    p = -exp(x(1:10)) + 1j*exp(x(11:20));
    r = x(21:30) + 1j*x(31:40);

    z = exp(1j*w);
    H = zeros(size(w));

    for n = 1:10
        pd = exp(p(n)/fs);

        H = H + (r(n)/fs)./(1-pd./z) ...
              + (conj(r(n))/fs)./(1-conj(pd)./z);
    end

    H = exp(x(41))*H;
end

% Passband and stopband constraints
function [c, ceq] = filter_constraints(x, w, pass, stop, fs)
    H = impulse_response(x, w, fs);
    mag = abs(H);

    c_pass = [mag(pass) - 1; ...
              10^(-1/20) - mag(pass)];

    c_stop = mag(stop) - 10^(-17/20);

    c = [c_pass(:); c_stop(:)];
    ceq = [];
end
