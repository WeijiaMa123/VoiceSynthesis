fs = 44100;
a6 = 0.24511241;
a5 = 0.07484454;
a4 = -1.4823002;
a3 = 2.29845421;
a2 = -2.63340862;
a1 = 2.49555074;
b = [1 a6 a5 a4 a3 a2 a1];
a = 1;
[H,w] = freqz(b,a);
f = (w/(2*pi))*fs;
figure;
plot(f, 20 * log10(abs(H))); % Normalize frequency to Nyquist frequency
xlabel('Frequency/Hz');
ylabel('Magnitude (dB)');
title('Frequency Response');
grid on;