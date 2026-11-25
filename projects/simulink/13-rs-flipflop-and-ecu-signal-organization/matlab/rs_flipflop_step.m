function q = rs_flipflop_step(s, r, qPrev)
% Active-high RS teaching reference. Simultaneous S/R is rejected here.
validateBinary(s,'S'); validateBinary(r,'R'); validateBinary(qPrev,'qPrev');
if logical(s) && logical(r)
    error('Issue13:SimultaneousSetReset','S and R cannot both be active in this exercise.');
elseif logical(s)
    q = 1;
elseif logical(r)
    q = 0;
else
    q = double(logical(qPrev));
end
end

function validateBinary(v,n)
if ~(isscalar(v) && (isnumeric(v)||islogical(v)) && isfinite(double(v)) && ...
        (double(v)==0 || double(v)==1))
    error('Issue13:InvalidBinaryInput','%s must be scalar 0 or 1.',n);
end
end
