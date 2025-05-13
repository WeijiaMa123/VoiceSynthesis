close all; clear all; clc;

%% load audio
[x, fs] = audioread('t.wav');

x = mean(x, 2); % mono
x = 0.9*x/max(abs(x)); % normalize

x = resample(x, 8000, fs);% resampling to 8kHz
fs = 8000;

w = hann(floor(0.03*fs), 'periodic'); % using 30ms Hann window
frame_length = length(w);
hop = length(w) / 2; % 50 percent overlap;

%% LPC encode with window
p = 12; % using 6th order
pitch_period = 80;
xhat = zeros(length(x),1);
for i = 1:hop:length(x)-frame_length
    frame = x(i:i+frame_length-1).*w;
    [a, G] = lpc(frame, p);      % a is length p+1, a(1)=1
    exc = randn(size(frame))/100;
    %exc = zeros(frame_length,1);
    for n = 1 : pitch_period : length(frame)
        exc(n) = exc(n);
    end
    G_exc = mean(exc.^2);
    exc = sqrt(G/G_exc)*exc; % making the power equal

    frame_hat = filter(1,a,exc);
    frame_hat = frame_hat.*w; % apply window again
    xhat(i:i+frame_length-1) =  xhat(i:i+frame_length-1) +frame_hat;
end
% sounds like bu needs both impulse train and noise, while some sounds
% might only need noise

%% additional bandpass filter
Wn = [80 500]/(fs/2);
[b2,a2] = butter(4,Wn,'bandpass');
xhat = filter(b2,a2,xhat);


%% LPC without window
% (1) Compute LPC coefficients and error power
[a, G] = lpc(x, p);      % a is length p+1, a(1)=1

% (2) Compute residual by applying the forward LPC filter to x
residual = filter(a, 1, x);

% (3) Reconstruct signal by applying the inverse filter to the residual
excitation = randn(size(x))/100;
pitch_period = 80;

for n = 1 : pitch_period : length(x)
    excitation(n) = excitation(n);
end
xhat = filter(1, a, excitation);
xhat = 5*xhat;

%% compare amount of data
plot(1:length(x),x,1:length(x),xhat,'--')
grid
xlabel('Sample Number')
ylabel('Amplitude')
legend('Original signal','LPC estimate')


%figure;
% Plot the histogram
%histogram(residual);
%% frequency response
[H,f] = freqz(1,a,1024,fs);
figure;
plot(f,20*log10(abs(H)));

%% compare frequency domain of 2 signal
NFFT = 8192;
Fx = fftshift(fft(x,NFFT));
Fxhat = fftshift(fft(xhat,NFFT));
f = linspace(-4000,4000,NFFT);
plot(f,10*log10(abs(Fx)),f,10*log10(abs(Fxhat)));
legend('Original signal','LPC estimate');
xlabel("frequency/Hz");
ylabel("dB");

%% play sound
soundsc(xhat);
%% save sound
audiowrite("t_output.wav",xhat,fs);

