function result = run_debounce_demo(p)
% RUN_DEBOUNCE_DEMO Base-MATLAB sample-count debounce example.
% This is an original teaching implementation, not a copy of the
% MathWorks Stateflow example. The official example uses temporal logic.

if nargin < 1 || isempty(p)
    p = demo_parameters();
end

validateattributes(p.DebounceTs, {'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(p.DebounceTime, {'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(p.DebounceStopTime, {'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(p.BounceDuration, {'numeric'}, ...
    {'scalar','real','finite','nonnegative'});

ratio = p.DebounceTime / p.DebounceTs;
requiredSamples = ceil(ratio - 1e-12);
if requiredSamples < 1
    requiredSamples = 1;
end

t = (0:p.DebounceTs:p.DebounceStopTime).';
intended = double(t >= p.SwitchOnTime & t < p.SwitchOffTime);
raw = intended;

% Simulate a short, deterministic contact-bounce interval at switch ON.
onMask = t >= p.SwitchOnTime & t < (p.SwitchOnTime + p.BounceDuration);
onPhase = floor((t(onMask) - p.SwitchOnTime) / (2*p.DebounceTs));
raw(onMask) = mod(onPhase, 2);

% Simulate a short, deterministic contact-bounce interval at switch OFF.
offMask = t >= p.SwitchOffTime & t < (p.SwitchOffTime + p.BounceDuration);
offPhase = floor((t(offMask) - p.SwitchOffTime) / (2*p.DebounceTs));
raw(offMask) = 1 - mod(offPhase, 2);

% A new candidate state is accepted only after enough consecutive samples.
debounced = zeros(size(raw));
candidate = raw(1);
stableCount = 1;
debounced(1) = raw(1);

for k = 2:numel(raw)
    if raw(k) == candidate
        stableCount = stableCount + 1;
    else
        candidate = raw(k);
        stableCount = 1;
    end

    debounced(k) = debounced(k-1);
    if candidate ~= debounced(k-1) && stableCount >= requiredSamples
        debounced(k) = candidate;
    end
end

data = table(t, intended, raw, debounced, ...
    'VariableNames', {'TimeS','IntendedState','RawInput','DebouncedOutput'});

edgeIdx = find(diff(debounced) ~= 0) + 1;
edgeTimes = t(edgeIdx);

result.Data = data;
result.RequiredSamples = requiredSamples;
result.EdgeTimes = edgeTimes;
result.Summary = struct( ...
    'DebounceTimeS', p.DebounceTime, ...
    'SampleTimeS', p.DebounceTs, ...
    'RequiredSamples', requiredSamples, ...
    'OutputTransitionCount', numel(edgeIdx), ...
    'FirstTransitionS', NaN, ...
    'SecondTransitionS', NaN);

if numel(edgeTimes) >= 1
    result.Summary.FirstTransitionS = edgeTimes(1);
end
if numel(edgeTimes) >= 2
    result.Summary.SecondTransitionS = edgeTimes(2);
end
end
