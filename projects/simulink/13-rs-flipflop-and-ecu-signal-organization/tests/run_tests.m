function report = run_tests()
root=fileparts(fileparts(mfilename('fullpath')));
rs=rs_flipflop_demo(); conv=data_type_conversion_demo();
ecu=organize_ecu_signals(fullfile(root,'data','ecu_signal_catalog.csv'));
t=rs.Data.TimeS; q=rs.Data.OutputQ; at=@(v)find(abs(t-v)<1e-10,1);
assert(q(at(0))==0); assert(q(at(1))==1); assert(q(at(2))==1);
assert(q(at(5.9))==1); assert(q(at(6))==0); assert(q(at(7))==0); assert(q(end)==0);
bad=false; try, rs_flipflop_step(1,1,0); catch e, bad=strcmp(e.identifier,'Issue13:SimultaneousSetReset'); end
assert(bad);
assert(isa(conv.Data.OutputSingle,'single'));
assert(isa(conv.Data.OutputUint8,'uint8'));
assert(isequal(double(conv.Data.OutputUint8),[0;0;12;13;255;255]));
assert(height(ecu.Summary)==7);
assert(sum(ecu.Summary.SignalCount)==height(ecu.Signals));
assert(numel(unique(ecu.Signals.SignalName))==height(ecu.Signals));
assert(all(ismember(ecu.Signals.DataType,["boolean","uint8","int16","single","double"])));
report.Passed=16; report.Total=16; report.Status='PASS';
fprintf('Issue 13 checks: %d/%d passed.\n',report.Passed,report.Total);
end
