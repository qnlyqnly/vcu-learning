function p = demo_parameters()
%DEMO_PARAMETERS Original fictional values for issue 10.
% Not from a vehicle project, company calibration, or CAN protocol.

p.battery.voltageV = 600;
p.battery.currentA = 125;                 % Teaching instantaneous current
p.battery.allowedDischargePowerKW = 75;   % Assumed BMS permission
p.battery.auxPowerKW = 5;                 % Same total-power accounting boundary

p.drive.efficiency = 0.90;                % DC input -> motor mechanical output
p.motor.speedRpm = 3000;
p.motor.allowedTorqueNm = 300;
p.driver.requestTorqueNm = 260;
p.mcu.allowedDriveTorqueNm = 240;
p.otherDriveLimitNm = 220;

p.driveline.ratio = 10;
p.driveline.efficiency = 0.95;            % Motor shaft -> wheels
p.wheel.effectiveRadiusM = 0.5;

p.vehicle.massKg = 2500;
p.vehicle.rollingCoefficient = 0.012;
p.vehicle.dragCoefficient = 0.30;
p.vehicle.frontalAreaM2 = 2.5;
p.vehicle.airDensityKgM3 = 1.225;
p.vehicle.gravityMps2 = 9.81;
p.vehicle.uphillGradePercent = 10;

p.regen.allowedChargePowerKW = 20;        % BMS DC-side charging limit
p.regen.efficiency = 0.90;                % Motor mechanical -> battery DC
p.regen.requestAbsTorqueNm = 160;
p.regen.mcuAllowedAbsTorqueNm = 120;
p.regen.motorAllowedAbsTorqueNm = 140;     % Separate generating torque ceiling

% Separate illustrative motor envelope for the plot.
p.motor.curveMaxTorqueNm = 400;
p.motor.curveMaxPowerKW = 100;
p.motor.curveMaxSpeedRpm = 10000;
end
