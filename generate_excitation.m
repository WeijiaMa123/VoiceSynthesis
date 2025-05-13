function excitation = generate_excitation(F0, duration, fs)
% Generate a glottal excitation waveform based on Rosenberg's preferred shape
% Inputs:
%   F0       - pitch frequency in Hz
%   duration - duration of the signal in samples
%   fs       - sampling frequency in Hz
% Output:
%   excitation - excitation signal

    T = 1 / F0;                % Pitch period
    Np = round(T * fs);        % Samples per period
    N_open = round(0.40 * Np); % Opening time (40%)
    N_close = round(0.16 * Np);% Closing time (16%)
    N_rest = Np - N_open - N_close;

    % One pulse
    t1 = linspace(0, pi, N_open);
    open_phase = 0.5 * (1 - cos(t1));  % Trigonometric rise (half-cosine)

    t2 = linspace(0, pi, N_close);
    close_phase = cos(t2);            % Sharp cosine fall
    close_phase = close_phase - min(close_phase); % end at 0
    close_phase = close_phase / max(close_phase); % height is 1

    rest = zeros(1, N_rest);         % No excitation in rest phase
    pulse = [open_phase, close_phase, rest];
    
    % Repeat for total duration
    num_periods = ceil(duration / Np);
    excitation = repmat(pulse, 1, num_periods);
    excitation = excitation(1:duration);     % Truncate to exact duration
    excitation = excitation / max(abs(excitation));
    excitation = excitation';
end
