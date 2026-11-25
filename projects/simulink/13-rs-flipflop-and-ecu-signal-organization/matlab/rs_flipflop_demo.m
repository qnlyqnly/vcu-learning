function result = rs_flipflop_demo()
% Active-high Set/Hold/Reset teaching sequence.
sampleTime = 0.1; stopTime = 10.0;
time = (0:sampleTime:stopTime).';
setInput = double(time >= 1.0 & time < 2.0);
resetInput = double(time >= 6.0 & time < 7.0);
outputQ = zeros(size(time));
for k = 2:numel(time)
    outputQ(k) = rs_flipflop_step(setInput(k), resetInput(k), outputQ(k-1));
end
result.Data = table(time, setInput, resetInput, outputQ, ...
    'VariableNames', {'TimeS','SetInputS','ResetInputR','OutputQ'});
end
