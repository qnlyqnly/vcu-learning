function report = run_tests()
%RUN_TESTS Execute issue 11 assertions in base MATLAB (no test toolbox).
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'matlab'), fullfile(root,'examples'));
p = demo_parameters();
cases = {'normal','low_voltage','neg_stuck','permit_removed', ...
    'pos_stuck','pre_stuck','pre_open_stuck','neg_feedback_loss', ...
    'ready_feedback_loss','request_removed','abort_requested','mcu_not_ready'};
expectedFaults = {'NONE','PRECHARGE_TIMEOUT','NEG_CLOSE_TIMEOUT','ABORTED', ...
    'POS_CLOSE_TIMEOUT','PRE_CLOSE_TIMEOUT','PRE_OPEN_TIMEOUT', ...
    'NEG_FEEDBACK_LOST','READY_FEEDBACK_LOST','ABORTED','ABORTED','NONE'};
for j = 1:numel(cases)
    out = simulate_precharge(p, cases{j});
    L = out.Log;
    check_invariants(L, p);
    assert(strcmp(out.summary.faultCode, expectedFaults{j}), ...
        'HV11:WrongFault', 'Unexpected fault in %s.', cases{j});
    switch cases{j}
        case {'normal','mcu_not_ready'}
            assert(strcmp(out.summary.finalState,'HV_READY') && L.HvReady(end));
            assert(abs(out.summary.nominalInitialCurrentA-6) < 1e-12);
            assert(abs(out.summary.theoreticalThresholdTimeS-2.396585818843) < 1e-10);
            firstCharge = find(L.PrechargeFb & L.MainNegFb,1);
            firstPosCmd = find(L.MainPosCmd,1);
            elapsed = L.TimeS(firstPosCmd)-L.TimeS(firstCharge);
            assert(elapsed >= out.summary.theoreticalThresholdTimeS-1e-9 && ...
                elapsed <= out.summary.theoreticalThresholdTimeS+p.dtS+1e-9);
            assert(all(diff(L.UbusV) >= -1e-9));
            assert(abs(max(L.IpreA)-6) < 1e-9);
            assert(L.MainNegFb(end) && L.MainPosFb(end) && ~L.PrechargeFb(end));
            if strcmp(cases{j},'mcu_not_ready')
                assert(~any(L.DriveReady));
            else
                assert(L.DriveReady(end));
            end
        case {'low_voltage','neg_stuck','pre_stuck'}
            assert(~any(L.MainPosCmd) && ~any(L.HvReady));
            assert(max(L.UbusV) == 0);
            if strcmp(cases{j},'neg_stuck')
                assert(any(L.MainNegCmd) && ~any(L.MainNegFb));
                assert(~any(L.PrechargeCmd) && ~any(L.PrechargeFb));
            end
        case {'permit_removed','request_removed','abort_requested', ...
                'neg_feedback_loss'}
            assert(any(L.StateCode == 2) && ~any(L.MainPosCmd));
            assert(~any(L.HvReady));
        case 'pos_stuck'
            assert(any(L.MainPosCmd) && ~any(L.MainPosFb) && ~any(L.HvReady));
            % PRE must remain commanded ON while POS is awaiting feedback.
            assert(all(L.PrechargeCmd(L.StateCode == 3)));
        case 'pre_open_stuck'
            assert(any(L.MainPosFb) && ~any(L.HvReady));
            assert(any(~L.PrechargeCmd & L.PrechargeFb & L.MainPosFb));
            % All commands OFF does not prove a stuck contact is open.
            assert(L.PrechargeFb(end));
        case 'ready_feedback_loss'
            assert(any(L.HvReady) && ~L.HvReady(end));
    end
    fprintf('PASS %02d %s\n', j, cases{j});
end
% Boundary: feedback exactly at the POS timeout is accepted before timeout.
q = p;
q.closeDelayS(3) = q.closeTimeoutS(3);
boundary = simulate_precharge(q,'normal');
check_invariants(boundary.Log, q);
assert(boundary.Log.HvReady(end), 'HV11:Boundary', 'Exact deadline rejected.');
fprintf('PASS 13 feedback_at_deadline\n');
% Invalid inputs must fail before producing a trace.
bad = {NaN, Inf, -1, 0, [1 2]};
for j = 1:numel(bad)
    q = p;
    q.capacitanceF = bad{j};
    failed = false;
    try
        simulate_precharge(q,'normal');
    catch
        failed = true;
    end
    assert(failed, 'HV11:InputValidation', 'Invalid capacitance accepted.');
end
fprintf('PASS 14 invalid_parameter_group (5 inputs)\n');
report.passed = 14;
report.failed = 0;
report.engine = version;
report.scenarios = cases;
fprintf('Issue 11: %d test groups passed in this MATLAB run.\n', report.passed);
end

function check_invariants(L, p)
assert(all(~L.PrechargeCmd | L.MainNegFb));
assert(all(~L.MainPosCmd | (L.MainNegFb & ...
    L.VoltageRatio >= p.completeRatio)));
posRise = L.MainPosCmd & ~[false; L.MainPosCmd(1:end-1)];
assert(all(L.PrechargeFb(posRise)));
assert(all(~L.MainPosCmd | L.PrechargeCmd | L.MainPosFb));
assert(all(~L.HvReady | (L.StateCode == 4 & L.MainNegFb & ...
    L.MainPosFb & ~L.PrechargeFb & L.VcuHvReq & L.HvPermit & ~L.AbortReq)));
assert(all(~L.DriveReady | (L.HvReady & L.McuHvOk & L.McuDriveReady)));
faultAt = find(L.StateCode == 5,1);
if ~isempty(faultAt)
    assert(all(L.StateCode(faultAt:end) == 5));
    assert(~any(L.MainNegCmd(faultAt:end) | L.PrechargeCmd(faultAt:end) | ...
        L.MainPosCmd(faultAt:end) | L.HvReady(faultAt:end)));
end
end
