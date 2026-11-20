function result = run_filter_demo(p)
% RUN_FILTER_DEMO Base-MATLAB first-order low-pass demonstration.
% This original IIR example is deliberately separate from the official
% MathWorks Basic Filter template, which uses a Lowpass FIR Filter block.

if nargin < 1 || isempty(p)
    p = demo_parameters();
end

validateattributes(p.FilterTs, {'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(p.FilterTau, {'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(p.FilterStopTime, {'numeric'}, ...
    {'scalar','real','finite','positive'});

t = (0:p.FilterTs:p.FilterStopTime).';
clean = sin(2*pi*p.SignalFrequency*t);

rng(p.RandomSeed, 'twister');
noise = p.NoiseStd .* randn(size(t));
interference = p.InterferenceAmplitude .* ...
    sin(2*pi*p.InterferenceFrequency*t);
noisy = clean + interference + noise;

% Exact zero-order-hold discretization of a first-order continuous pole:
% y[k] = a*y[k-1] + (1-a)*u[k], a = exp(-Ts/tau).
a = exp(-p.FilterTs / p.FilterTau);
filtered = zeros(size(noisy));
filteredClean = zeros(size(clean));
filtered(1) = noisy(1);
filteredClean(1) = clean(1);

for k = 2:numel(t)
    filtered(k) = a*filtered(k-1) + (1-a)*noisy(k);
    filteredClean(k) = a*filteredClean(k-1) + (1-a)*clean(k);
end

rawResidual = noisy - clean;
filteredResidual = filtered - filteredClean;
settleMask = t >= 0.25;

data = table(t, clean, noisy, filtered, filteredClean, ...
    rawResidual, filteredResidual, ...
    'VariableNames', {'TimeS','CleanSignal','NoisyInput','FilteredOutput', ...
    'FilteredCleanReference','RawResidual','FilteredResidual'});

result.Data = data;
result.Alpha = a;
result.Summary = struct( ...
    'SampleTimeS', p.FilterTs, ...
    'TimeConstantS', p.FilterTau, ...
    'Alpha', a, ...
    'RawResidualStd', std(rawResidual(settleMask)), ...
    'FilteredResidualStd', std(filteredResidual(settleMask)));

end
