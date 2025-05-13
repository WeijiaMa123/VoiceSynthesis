close all; clear all; clc;

%% load audio
[x, fs] = audioread('aa.wav');

x = mean(x, 2); % mono
x = 0.9*x/max(abs(x)); % normalize

x = resample(x, 8000, fs);% resampling to 8kHz
fs = 8000;

w = hann(floor(0.03*fs), 'periodic'); % using 30ms Hann window
frame_length = length(w);
hop = length(w) / 2; % 50 percent overlap;

%% LPC with attempt to use roseberg excitation

p = 12; % number of pole
xhat = zeros(length(x),1);
f_pitch = 125;
pitch_period = round(fs/f_pitch);

for i = 1:hop:length(x)-frame_length
    frame = x(i:i+frame_length-1).*w;
    [a, G] = lpc(frame, p);      % a is length p+1, a(1)=1
    %exc = randn(size(frame))/100;
    exc = generate_excitation(pitch_period,frame_length,fs);    
    G_exc = mean(exc.^2);
    exc = sqrt(G/G_exc)*exc;
    frame_hat = filter(1,a,exc);
    frame_hat = frame_hat.*w; % apply window again
    xhat(i:i+frame_length-1) = xhat(i:i+frame_length-1)+frame_hat;
end


%% compare amount of data
plot(1:length(x),x,1:length(x),xhat,'--')
grid
xlabel('Sample Number')
ylabel('Amplitude')
legend('Original signal','LPC estimate')


%% compare frequency domain of 2 signal
NFFT = 8192;
Fx = fftshift(fft(x,NFFT));
Fxhat = fftshift(fft(xhat,NFFT));
f = linspace(-4000,4000,NFFT);
figure;
plot(f,20*log10(abs(Fx)),f,20*log10(abs(Fxhat)));
legend('Original signal','LPC estimate')
xlim([-1200,1200]);
xlabel("frequency/hz");
ylabel("dB");


%% frequency response
[H,f] = freqz(1,a,1024,fs);
figure;
plot(f,20*log10(abs(H)));
xlabel("frequency/Hz");
ylabel("dB");

%% play sound
[b2, a2] = butter(2, 20 / (fs/2), 'high');  % 2nd-order high-pass filter

% Apply the filter
xhat2 = filter(b2, a2, xhat);            % x is your input signal
soundsc(xhat2);

%% 
figure;
plot(1:5032,residual,1:5032,excitation);
residualf = fftshift(fft(residual,NFFT));
excf = fftshift(fft(excitation,NFFT));
figure;
plot(f,excf,f,residualf);

%%
figure;
plot(1:240,exc);
xlabel("samples");
title("Rosenberg pulse");