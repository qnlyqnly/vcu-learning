function report = run_tests()
% Basic regression assertions for Issue 13 teaching examples.
rs = rs_flipflop_demo(); conversion = data_type_conversion_demo();
thisDir = fileparts(mfilename('fullpath')); projectDir = fileparts(thisDir);
ecu = organize_ecu_signals(fullfile(projectDir,'data','ecu_signal_catalog.csv'));
idx = @(t) find(abs(rs.Data.TimeS-t)<1e-10,1);
assert(rs.Data.OutputQ(1)==0);
assert(rs.Data.OutputQ(idx(1.0))==1);
assert(rs.Data.OutputQ(idx(2.0))==1);
assert(rs.Data.OutputQ(idx(6.0))==0);
assert(rs.Data.OutputQ(end)==0);
rejected = false;
try, rs_flipflop_step(1,1,0);
catch e, rejected = strcmp(e.identifier,'Issue13:SimultaneousSetReset'); end
assert(rejected);
assert(isa(conversion.Data.OutputSingle,'single'));
assert(isa(conversion.Data.OutputUint8,'uint8'));
assert(isequal(conversion.Data.OutputUint8, uint8([0;0;12;13;255;255])));
assert(height(ecu.Signals)==11);
assert(height(ecu.Summary)==7);
assert(isequal(ecu.Summary.ECU, ["ABS";"BMS";"MCU";"BCM";"DCDC";"OBC";"TBOX"]));
assert(isequal(ecu.Summary.SignalCount, [3;2;2;1;1;1;1]));
report.Status = 'PASS'; report.Passed = 13; report.Total = 13;
fprintf('Issue 13 MATLAB assertions: 13/13 passed.\n');
end
