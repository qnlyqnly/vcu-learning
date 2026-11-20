function p = demo_parameters()
% DEMO_PARAMETERS Parameters for the Issue 12 debounce/filter learning demo.
% All values are original teaching assumptions, not vehicle calibration data.

p.DebounceTs = 0.001;          % s, 1 ms discrete sample
p.DebounceStopTime = 0.80;     % s
p.SwitchOnTime = 0.150;        % s, intended switch ON time
p.SwitchOffTime = 0.450;       % s, intended switch OFF time
p.BounceDuration = 0.010;      % s, simulated contact bounce interval
p.DebounceTime = 0.010;        % s, required continuous stable input

p.FilterTs = 0.001;            % s
p.FilterStopTime = 2.0;        % s
p.SignalFrequency = 1.5;       % Hz, useful low-frequency component
p.InterferenceFrequency = 30;  % Hz, deliberately added high-frequency component
p.InterferenceAmplitude = 0.25;
p.NoiseStd = 0.12;             % zero-mean Gaussian noise standard deviation
p.FilterTau = 0.025;           % s, first-order low-pass time constant
p.RandomSeed = 12;             % reproducible MATLAB random sequence
end
