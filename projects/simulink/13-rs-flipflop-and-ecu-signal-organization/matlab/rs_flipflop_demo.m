function out = rs_flipflop_demo()
% Teaching timing only: S pulse 1-2 s; R pulse 6-7 s.
t = (0:0.1:8)';
s = double(t>=1 & t<2);
r = double(t>=6 & t<7);
q = zeros(size(t));
for k=2:numel(t), q(k)=rs_flipflop_step(s(k),r(k),q(k-1)); end
out.Data = table(t,s,r,q,'VariableNames',{'TimeS','SetS','ResetR','OutputQ'});
out.RiseTimesS = t(find(diff(q)>0)+1);
out.FallTimesS = t(find(diff(q)<0)+1);
end
