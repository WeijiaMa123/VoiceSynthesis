close all; clear all; clc;

%% load audio
[x, fs] = audioread('aa.wav');

x = mean(x, 2); % mono
x = 0.9*x/max(abs(x)); % normalize

x = resample(x, 8000, fs);% resampling to 8kHz
fs = 8000;

w = hann(floor(0.03*fs), 'periodic'); % using 30ms Hann window


%% LPC encode 
p = 6; % using 6th order

% (1) Compute LPC coefficients and error power
[a, G] = lpc(x, p);      % a is length p+1, a(1)=1

% (2) Compute residual by applying the forward LPC filter to x
residual = filter(a, 1, x);

% (3) Reconstruct signal by applying the inverse filter to the residual
excitation = randn(size(x))/500;
pitch_period = 300;

for n = 1 : pitch_period : length(x)
    excitation(n) = excitation(n) + 0.1;
end
xhat = filter(1, a, excitation);


%% compare amount of data
plot(1:5032,x,1:5032,xhat,'--')
grid
xlabel('Sample Number')
ylabel('Amplitude')
legend('Original signal','LPC estimate')


%% compare frequency domain of 2 signal
NFFT = 8192;
Fx = fftshift(fft(x,NFFT));
Fxhat = fftshift(fft(xhat,NFFT));
f = linspace(-4000,4000,NFFT);
plot(f,abs(Fx),f,abs(Fxhat));
legend('Original signal','LPC estimate')


%% play sound

soundsc(xhat)