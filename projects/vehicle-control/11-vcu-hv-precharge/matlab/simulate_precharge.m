function out = simulate_precharge(p, scenario)
%SIMULATE_PRECHARGE Discrete three-contactor teaching controller and plant.
% out = simulate_precharge(demo_parameters(), 'normal');
% Commands are controller outputs; feedback is a delayed actuator model.
% No Simulink/Stateflow or additional toolbox is required.
if nargin < 2
    scenario = 'normal';
end
scenario = validatestring(scenario, {'normal','low_voltage','neg_stuck', ...
    'permit_removed','pos_stuck','pre_stuck','pre_open_stuck', ...
    'neg_feedback_loss','ready_feedback_loss','request_removed', ...
    'abort_requested','mcu_not_ready'});
check_parameters(p);

dt = p.dtS;
time = (0:floor(p.durationS / dt + 1e-9))' * dt;
n = numel(time);
tau = p.resistanceOhm * p.capacitanceF;
names = {'OFF','CLOSE_NEG','PRECHARGE','CLOSE_POS','HV_READY','FAULT'};
% State codes 0..5. Every row is the sample AFTER controller evaluation.
state = 0;
entered = 1;
preConfirmed = false;
posConfirmed = false;
chargeStart = NaN;
preRelease = NaN;
fault = 'NONE';
cmd = false(1,3);
fb = false(1,3);
actuatorTicks = zeros(1,3);
u = 0;
stateCode = zeros(n,1);
stateName = cell(n,1);
faultCode = cell(n,1);
commands = false(n,3);
feedback = false(n,3);
busV = zeros(n,1);
currentA = zeros(n,1);
ready = false(n,1);
request = false(n,1);
permit = false(n,1);
abort = false(n,1);
closeTicks = ceil(p.closeDelayS / dt - 1e-9);
openTicks = ceil(p.openDelayS / dt - 1e-9);
timeoutTicks = ceil(p.closeTimeoutS / dt - 1e-9);
preTimeoutTicks = ceil(p.prechargeTimeoutS / dt - 1e-9);
releaseTimeoutTicks = ceil(p.preOpenTimeoutS / dt - 1e-9);
failClose = [strcmp(scenario,'neg_stuck'), ...
    strcmp(scenario,'pre_stuck'), strcmp(scenario,'pos_stuck')];
failOpen = [false, strcmp(scenario,'pre_open_stuck'), false];
chargingHealthy = ~strcmp(scenario,'low_voltage');

for k = 1:n
    t = time(k);
    if k > 1
        % Integrate over [t(k-1), t(k)) using previous physical contacts.
        if fb(1) && fb(3)
            u = p.batteryV;  % Ideal main path: closing transient not modelled
        elseif fb(1) && fb(2) && chargingHealthy
            u = p.batteryV - (p.batteryV-u) * exp(-dt/tau);
        end
        % Only PREVIOUS commands can move the actuators at this sample.
        [fb, actuatorTicks] = contactor_step(cmd, fb, actuatorTicks, ...
            closeTicks, openTicks, failClose, failOpen);
    end
    if strcmp(scenario,'neg_feedback_loss') && t >= 1.0 - dt*1e-6
        fb(1) = false;
    end
    if strcmp(scenario,'ready_feedback_loss') && t >= 4.0 - dt*1e-6
        fb(3) = false;
    end
    if fb(1) && fb(3)
        u = p.batteryV;
    end
    request(k) = t >= p.requestOnS - dt*1e-6;
    permit(k) = true;
    if t >= 1.0 - dt*1e-6
        if strcmp(scenario,'permit_removed')
            permit(k) = false;
        elseif strcmp(scenario,'request_removed')
            request(k) = false;
        elseif strcmp(scenario,'abort_requested')
            abort(k) = true;
        end
    end
    ratio = u / p.batteryV;
    next = state;
    age = k - entered;
    % Abort/loss of permission has priority over EVERY normal transition.
    if state ~= 0 && state ~= 5 && ...
            (~request(k) || ~permit(k) || abort(k))
        next = 5;
        fault = 'ABORTED';
    else
        switch state
            case 0  % OFF
                if any(fb)
                    next = 5;
                    fault = 'OFF_FEEDBACK_CLOSED';
                elseif request(k) && permit(k) && ~abort(k)
                    next = 1;
                end
            case 1  % CLOSE_NEG: precharge command still OFF
                if fb(1)
                    next = 2;
                elseif age >= timeoutTicks(1)
                    next = 5;
                    fault = 'NEG_CLOSE_TIMEOUT';
                end
            case 2  % PRECHARGE: two INDEPENDENT timing windows
                if ~fb(1)
                    next = 5;
                    fault = 'NEG_FEEDBACK_LOST';
                else
                    if ~preConfirmed
                        if fb(2)
                            preConfirmed = true;
                            chargeStart = k;
                        elseif age >= timeoutTicks(2)
                            next = 5;
                            fault = 'PRE_CLOSE_TIMEOUT';
                        end
                    end
                    if preConfirmed
                        chargeAge = k - chargeStart;
                        if ~fb(2)
                            next = 5;
                            fault = 'PRE_FEEDBACK_LOST';
                        elseif ratio >= p.completeRatio && ...
                                chargeAge <= preTimeoutTicks
                            next = 3;
                        elseif chargeAge >= preTimeoutTicks
                            next = 5;
                            fault = 'PRECHARGE_TIMEOUT';
                        end
                    end
                end
            case 3  % CLOSE_POS: hold PRE until actual POS confirmation
                if ~fb(1)
                    next = 5;
                    fault = 'NEG_FEEDBACK_LOST';
                elseif ~posConfirmed
                    if ~fb(2)
                        next = 5;
                        fault = 'PRE_FEEDBACK_LOST';
                    elseif fb(3)
                        posConfirmed = true;
                        preRelease = k;
                    elseif age >= timeoutTicks(3)
                        next = 5;
                        fault = 'POS_CLOSE_TIMEOUT';
                    end
                elseif ~fb(3)
                    next = 5;
                    fault = 'POS_FEEDBACK_LOST';
                elseif ~fb(2)
                    next = 4;
                elseif k - preRelease >= releaseTimeoutTicks
                    next = 5;
                    fault = 'PRE_OPEN_TIMEOUT';
                end
            case 4  % HV_READY: continue monitoring actual contacts/voltage
                if ~fb(1) || ~fb(3) || fb(2) || ratio < p.completeRatio
                    next = 5;
                    fault = 'READY_FEEDBACK_LOST';
                end
            case 5  % Latched until a NEW simulation; never auto-retry
                next = 5;
        end
    end
    if next ~= state
        entered = k;
    end
    state = next;
    switch state
        case 1
            cmd = [true, false, false];
        case 2
            cmd = [true, true, false];
        case 3
            cmd = [true, ~posConfirmed, true];
        case 4
            cmd = [true, false, true];
        otherwise
            cmd = [false, false, false];
    end
    % Physical resistor current, not the nominal initial-current formula.
    if fb(1) && fb(2) && ~fb(3) && chargingHealthy
        currentA(k) = max(0, (p.batteryV-u) / p.resistanceOhm);
    end
    ready(k) = state == 4 && fb(1) && fb(3) && ~fb(2) && ...
        request(k) && permit(k) && ~abort(k) && ratio >= p.completeRatio;
    stateCode(k) = state;
    stateName{k} = names{state+1};
    faultCode{k} = fault;
    commands(k,:) = cmd;
    feedback(k,:) = fb;
    busV(k) = u;
end
mcuHv = repmat(logical(p.mcuHvOk), n, 1);
mcuDrive = repmat(logical(p.mcuDriveReady) && ...
    ~strcmp(scenario,'mcu_not_ready'), n, 1);
out.Log = table(time, stateCode, stateName, request, permit, abort, ...
    commands(:,1), commands(:,2), commands(:,3), ...
    feedback(:,1), feedback(:,2), feedback(:,3), ...
    repmat(p.batteryV,n,1), busV, busV/p.batteryV, currentA, ready, ...
    mcuHv, mcuDrive, ready & mcuHv & mcuDrive, faultCode, ...
    'VariableNames', {'TimeS','StateCode','State','VcuHvReq','HvPermit', ...
    'AbortReq','MainNegCmd','PrechargeCmd','MainPosCmd','MainNegFb', ...
    'PrechargeFb','MainPosFb','UbattV','UbusV','VoltageRatio','IpreA', ...
    'HvReady','McuHvOk','McuDriveReady','DriveReady','FaultCode'});
out.scenario = scenario;
out.parameters = p;
out.summary.tauS = tau;
out.summary.nominalInitialCurrentA = p.batteryV / p.resistanceOhm;
out.summary.theoreticalThresholdTimeS = -tau * log(1-p.completeRatio);
out.summary.finalState = stateName{end};
out.summary.faultCode = fault;
out.summary.readyTimeS = NaN;
firstReady = find(ready, 1);
if ~isempty(firstReady)
    out.summary.readyTimeS = time(firstReady);
end
end

function [fb, ticks] = contactor_step(cmd, fb, ticks, closeTicks, ...
        openTicks, failClose, failOpen)
% Feedback is intentionally NOT assigned directly from the command.
for j = 1:3
    if cmd(j) == fb(j)
        ticks(j) = 0;
    elseif (cmd(j) && failClose(j)) || (~cmd(j) && failOpen(j))
        ticks(j) = 0;
    else
        ticks(j) = ticks(j) + 1;
        if cmd(j)
            delay = closeTicks(j);
        else
            delay = openTicks(j);
        end
        if ticks(j) >= delay
            fb(j) = cmd(j);
            ticks(j) = 0;
        end
    end
end
end

function check_parameters(p)
fields = {'batteryV','resistanceOhm','capacitanceF','prechargeTimeoutS', ...
    'dtS','durationS','preOpenTimeoutS'};
for j = 1:numel(fields)
    validateattributes(p.(fields{j}), {'numeric'}, ...
        {'scalar','real','finite','positive'}, mfilename, fields{j});
end
validateattributes(p.completeRatio, {'numeric'}, ...
    {'scalar','real','finite','>',0,'<',1}, mfilename, 'completeRatio');
validateattributes(p.requestOnS, {'numeric'}, ...
    {'scalar','real','finite','nonnegative'}, mfilename, 'requestOnS');
vectors = {'closeDelayS','openDelayS','closeTimeoutS'};
for j = 1:numel(vectors)
    validateattributes(p.(vectors{j}), {'numeric'}, ...
        {'row','numel',3,'real','finite','positive'}, mfilename, vectors{j});
end
flags = {'mcuHvOk','mcuDriveReady'};
for j = 1:numel(flags)
    validateattributes(p.(flags{j}), {'numeric','logical'}, ...
        {'scalar','real','finite','binary'}, mfilename, flags{j});
end
assert(p.durationS >= p.dtS && p.requestOnS < p.durationS, ...
    'HV11:InvalidHorizon', 'Simulation must include request and time steps.');
assert(isfinite(p.resistanceOhm * p.capacitanceF) && ...
    p.resistanceOhm * p.capacitanceF > 0, ...
    'HV11:InvalidTau', 'R*C must be a finite positive number.');
assert(p.durationS / p.dtS <= 1e6, ...
    'HV11:TooManySteps', 'Use at most 1e6 time intervals.');
end
