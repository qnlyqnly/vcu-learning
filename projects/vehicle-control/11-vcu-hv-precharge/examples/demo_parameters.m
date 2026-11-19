function p = demo_parameters()
%DEMO_PARAMETERS Issue 11: original offline teaching assumptions only.
% No vehicle calibration, company model, CAN traffic or hardware I/O.
p.batteryV = 600;
p.resistanceOhm = 100;
p.capacitanceF = 0.008;       % NEW teaching assumption, not a CSDN/vehicle value
p.completeRatio = 0.95;
p.prechargeTimeoutS = 3.0;   % Starts at confirmed precharge contact closure
p.dtS = 0.01;
p.durationS = 5.0;
p.requestOnS = 0.10;
% The three elements are [main negative, precharge, main positive].
p.closeDelayS = [0.05, 0.05, 0.05];
p.openDelayS = [0.03, 0.03, 0.03];
p.closeTimeoutS = [0.30, 0.30, 0.30];
p.preOpenTimeoutS = 0.30;
p.mcuHvOk = true;            % Independent simulated MCU status inputs
p.mcuDriveReady = true;
end
