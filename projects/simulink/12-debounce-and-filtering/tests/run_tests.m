function report = run_tests()
% RUN_TESTS Regression checks for the original base-MATLAB demos.
% Run from the project root after adding matlab/, examples/ and tests/.

p = demo_parameters();
d = run_debounce_demo(p);
f = run_filter_demo(p);

passed = 0;
total = 0;

% 1) Debounced output must have exactly two real state transitions.
total = total + 1;
assert(d.Summary.OutputTransitionCount == 2, ...
    'Debounce output should have exactly two transitions.');
passed = passed + 1;

% 2) First accepted transition must occur after the ON bounce interval
%    plus the required consecutive stable samples.
total = total + 1;
nStable = ceil(p.DebounceTime/p.DebounceTs - 1e-12);
expectedOn = p.SwitchOnTime + p.BounceDuration + (nStable-1)*p.DebounceTs;
assert(abs(d.Summary.FirstTransitionS - expectedOn) < p.DebounceTs/10, ...
    'Unexpected debounce ON transition time.');
passed = passed + 1;

% 3) OFF transition must be delayed in the same way.
total = total + 1;
expectedOff = p.SwitchOffTime + p.BounceDuration + (nStable-1)*p.DebounceTs;
assert(abs(d.Summary.SecondTransitionS - expectedOff) < p.DebounceTs/10, ...
    'Unexpected debounce OFF transition time.');
passed = passed + 1;

% 4) The raw signal really does contain repeated transitions in both bounce windows.
total = total + 1;
raw = d.Data.RawInput;
t = d.Data.TimeS;
onWindow = t >= p.SwitchOnTime & t < p.SwitchOnTime+p.BounceDuration;
offWindow = t >= p.SwitchOffTime & t < p.SwitchOffTime+p.BounceDuration;
assert(sum(diff(raw(onWindow)) ~= 0) >= 3 && ...
       sum(diff(raw(offWindow)) ~= 0) >= 3, ...
    'The synthetic input should contain multiple bounce edges.');
passed = passed + 1;

% 5) Debounced output must remain OFF throughout the ON bounce interval.
total = total + 1;
check = t >= p.SwitchOnTime & t < p.SwitchOnTime+p.BounceDuration;
assert(all(d.Data.DebouncedOutput(check) == 0), ...
    'Debouncer reacted during the ON bounce interval.');
passed = passed + 1;

% 6) Debounced output must remain ON throughout the OFF bounce interval.
total = total + 1;
check = t >= p.SwitchOffTime & t < p.SwitchOffTime+p.BounceDuration;
assert(all(d.Data.DebouncedOutput(check) == 1), ...
    'Debouncer reacted during the OFF bounce interval.');
passed = passed + 1;

% 7) The discrete filter coefficient must describe a stable pole.
total = total + 1;
assert(f.Alpha > 0 && f.Alpha < 1, ...
    'First-order low-pass coefficient must be between 0 and 1.');
passed = passed + 1;

% 8) Filtered high-frequency residual must be smaller than raw residual.
total = total + 1;
assert(f.Summary.FilteredResidualStd < f.Summary.RawResidualStd, ...
    'The filter should reduce the injected high-frequency residual.');
passed = passed + 1;

% 9) Filter output must be finite.
total = total + 1;
assert(all(isfinite(f.Data.FilteredOutput)), ...
    'Filtered output contains NaN or Inf.');
passed = passed + 1;

% 10) Filtered output must not be identical to noisy input.
total = total + 1;
assert(any(abs(f.Data.FilteredOutput-f.Data.NoisyInput) > 1e-9), ...
    'Filter output unexpectedly equals its input.');
passed = passed + 1;

report.Passed = passed;
report.Total = total;
report.Status = 'PASS';
fprintf('Issue 12 MATLAB tests: %d/%d passed.\n', passed, total);
end
