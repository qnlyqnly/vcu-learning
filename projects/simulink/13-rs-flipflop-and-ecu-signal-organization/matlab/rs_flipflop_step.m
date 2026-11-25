function q = rs_flipflop_step(setInput, resetInput, previousQ)
% Active-high RS teaching reference; not a claim about every Simulink block.
validateBinaryScalar(setInput, 'setInput');
validateBinaryScalar(resetInput, 'resetInput');
validateBinaryScalar(previousQ, 'previousQ');
s = logical(setInput); r = logical(resetInput); qPrev = logical(previousQ);
if s && r
    error('Issue13:SimultaneousSetReset', 'S and R are both active; invalid in this teaching example.');
elseif s
    q = 1;
elseif r
    q = 0;
else
    q = double(qPrev);
end
end
function validateBinaryScalar(value, name)
validType = isnumeric(value) || islogical(value);
validValue = isscalar(value) && validType && isfinite(double(value)) && ...
    (double(value)==0 || double(value)==1);
if ~validValue
    error('Issue13:InvalidBinaryInput', '%s must be scalar logical or numeric 0/1.', name);
end
end
