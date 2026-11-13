function results = run_all_examples(makePlot)
%RUN_ALL_EXAMPLES Run original, non-production VCU calculation examples.
% Example from project root:
%   addpath(fullfile(pwd,'matlab'), fullfile(pwd,'examples'));
%   results = run_all_examples(false);
%
% Setting makePlot=true generates figures/motor_torque_speed_generated.png.

if nargin == 0
    makePlot = false;
end
assert(isscalar(makePlot) && (islogical(makePlot) || isnumeric(makePlot)) && ...
    isreal(makePlot) && isfinite(makePlot) && any(makePlot == [0, 1]), ...
    'makePlot must be a scalar true/false value.');

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'examples'));
p = demo_parameters();

power = calc_power_torque(p);
vehicle = calc_vehicle_dynamics(p, power.finalPositiveTorqueNm);

% Parameter-independent consistency checks also work after editing demo values.
% Reference values for the original parameters are in expected_results.txt.
tol = 1e-9;
assert(abs(power.batteryMeasuredPowerKW - ...
    p.battery.voltageV * p.battery.currentA / 1000) < tol);
assert(power.finalPositiveTorqueNm >= 0 && ...
    power.finalPositiveTorqueNm <= power.powerTorqueLimitNm + tol);
assert(power.finalRegenTorqueNm <= 0 && ...
    abs(power.finalRegenTorqueNm) <= power.regenPowerTorqueAbsLimitNm + tol);
assert(abs(vehicle.speedKph - 3.6 * vehicle.speedMps) < tol);
assert(abs(vehicle.tractiveForceN * p.wheel.effectiveRadiusM - ...
    vehicle.wheelTorqueNm) < tol);
assert(abs(vehicle.accelerationFlatMps2 * p.vehicle.massKg - ...
    (vehicle.tractiveForceN - vehicle.aerodynamicDragN - ...
     vehicle.rollingFlatN)) < tol);

fprintf('\n=== Issue 10: original VCU powertrain formula example ===\n');
fprintf('Measured DC power (not BMS permission): %.3f kW\n', power.batteryMeasuredPowerKW);
fprintf('Drive DC allowance after listed aux load: %.3f kW\n', power.dcPowerAvailableToDriveKW);
fprintf('Motor mechanical power allowance: %.3f kW\n', power.motorMechanicalPowerKW);
fprintf('Power-equivalent torque ceiling: %.3f N*m\n', power.powerTorqueLimitNm);
fprintf('Final positive motor torque request: %.3f N*m\n', power.finalPositiveTorqueNm);
fprintf('Theoretical speed: %.3f km/h\n', vehicle.speedKph);
fprintf('Wheel tractive force: %.3f N\n', vehicle.tractiveForceN);
fprintf('Flat-road acceleration (simple model): %.4f m/s^2\n', vehicle.accelerationFlatMps2);
fprintf('10%% uphill acceleration (simple model): %.4f m/s^2\n', vehicle.accelerationUphillMps2);
fprintf('Regenerative motor torque request: %.3f N*m\n', power.finalRegenTorqueNm);
fprintf('Numeric assertions completed in this run.\n');

results.parameters = p;
results.power = power;
results.vehicle = vehicle;
if logical(makePlot)
    results.generatedFigure = plot_motor_curve_demo(p);
else
    results.generatedFigure = '';
end
end
