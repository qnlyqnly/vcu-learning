function out = calc_power_torque(p)
%CALC_POWER_TORQUE Battery power and positive/negative motor torque limits.
% P in kW, motor torque in N*m, motor speed in rpm.
% The 9550 coefficient is a common engineering approximation.

U = p.battery.voltageV;
I = p.battery.currentA;
Pallow = p.battery.allowedDischargePowerKW;
Paux = p.battery.auxPowerKW;
etaDrive = p.drive.efficiency;
n = p.motor.speedRpm;

% Reject NaN, Inf, complex values and vector inputs before scalar algebra.
positiveValues = {U, n};
for k = 1:numel(positiveValues)
    validateattributes(positiveValues{k}, {'numeric'}, ...
        {'real','finite','scalar','positive'}, mfilename);
end
nonnegativeValues = {I, Pallow, Paux, p.driver.requestTorqueNm, ...
    p.mcu.allowedDriveTorqueNm, p.motor.allowedTorqueNm, p.otherDriveLimitNm, ...
    p.regen.allowedChargePowerKW, p.regen.requestAbsTorqueNm, ...
    p.regen.mcuAllowedAbsTorqueNm, p.regen.motorAllowedAbsTorqueNm};
for k = 1:numel(nonnegativeValues)
    validateattributes(nonnegativeValues{k}, {'numeric'}, ...
        {'real','finite','scalar','nonnegative'}, mfilename);
end
efficiencies = {etaDrive, p.regen.efficiency};
for k = 1:numel(efficiencies)
    validateattributes(efficiencies{k}, {'numeric'}, ...
        {'real','finite','scalar','>',0,'<=',1}, mfilename);
end

assert(isscalar(U) && U > 0 && isfinite(U), 'Battery voltage must be positive.');
assert(isscalar(I) && I >= 0 && isfinite(I), 'Example current must be nonnegative.');
assert(Pallow >= 0 && Paux >= 0 && Paux <= Pallow, ...
    'Power limits must be nonnegative and auxiliary load <= BMS limit.');
assert(etaDrive > 0 && etaDrive <= 1, 'Drive efficiency must be within (0, 1].');
assert(n > 0 && isfinite(n), 'This power-based example requires motor speed > 0 rpm.');

out.batteryMeasuredPowerKW = U * I / 1000;
% Important: measured battery power is NOT a BMS permission value.
out.bmsAllowedPowerKW = Pallow;
% Assumption: Pallow covers the listed auxiliary DC loads.
out.dcPowerAvailableToDriveKW = Pallow - Paux;
out.motorMechanicalPowerKW = out.dcPowerAvailableToDriveKW * etaDrive;
out.powerTorqueLimitNm = 9550 * out.motorMechanicalPowerKW / n;

limits = [p.driver.requestTorqueNm, ...
          p.mcu.allowedDriveTorqueNm, ...
          p.motor.allowedTorqueNm, ...
          p.otherDriveLimitNm, ...
          out.powerTorqueLimitNm];
assert(all(isfinite(limits)) && all(limits >= 0), ...
    'Positive-drive torque limits must be finite and nonnegative.');
out.finalPositiveTorqueNm = min(limits);

% Forward rotation only (n > 0): negative torque means braking.
% etaRegen covers motor/inverter -> battery DC; no gearbox conversion here.
% Auxiliary consumption during regen is ignored (no extra charging headroom).
% Regen uses its own negative-torque convention and a DC-side charge limit.
etaRegen = p.regen.efficiency;
assert(etaRegen > 0 && etaRegen <= 1, 'Regen efficiency must be within (0, 1].');
assert(p.regen.allowedChargePowerKW >= 0, 'BMS charge power must be nonnegative.');
regenMechanicalLimitKW = p.regen.allowedChargePowerKW / etaRegen;
out.regenMechanicalPowerLimitKW = regenMechanicalLimitKW;
out.regenPowerTorqueAbsLimitNm = 9550 * regenMechanicalLimitKW / abs(n);
regenLimits = [p.regen.requestAbsTorqueNm, ...
               p.regen.mcuAllowedAbsTorqueNm, ...
               p.regen.motorAllowedAbsTorqueNm, ...
               out.regenPowerTorqueAbsLimitNm];
assert(all(isfinite(regenLimits)) && all(regenLimits >= 0), ...
    'Regen magnitude limits must be finite and nonnegative.');
out.finalRegenTorqueNm = -min(regenLimits);
end
