function out = calc_vehicle_dynamics(p, positiveTorqueNm)
%CALC_VEHICLE_DYNAMICS Simple single-speed forward-driving vehicle model.
% Inputs: motor torque N*m, motor speed rpm, gear ratio > 0, wheel radius m.
% Excludes rotary inertia, tire slip, load transfer and efficiency maps.

m = p.vehicle.massKg;
g = p.vehicle.gravityMps2;
ratio = p.driveline.ratio;
etaGear = p.driveline.efficiency;
r = p.wheel.effectiveRadiusM;
n = p.motor.speedRpm;

positiveValues = {m, g, ratio, r};
for k = 1:numel(positiveValues)
    validateattributes(positiveValues{k}, {'numeric'}, ...
        {'real','finite','scalar','positive'}, mfilename);
end
nonnegativeValues = {n, positiveTorqueNm, p.vehicle.airDensityKgM3, ...
    p.vehicle.dragCoefficient, p.vehicle.frontalAreaM2, ...
    p.vehicle.rollingCoefficient, p.vehicle.uphillGradePercent};
for k = 1:numel(nonnegativeValues)
    validateattributes(nonnegativeValues{k}, {'numeric'}, ...
        {'real','finite','scalar','nonnegative'}, mfilename);
end
validateattributes(etaGear, {'numeric'}, ...
    {'real','finite','scalar','>',0,'<=',1}, mfilename);

assert(m > 0 && g > 0 && ratio > 0 && r > 0 && n >= 0, ...
    'Vehicle mass, gravity, ratio and radius must be positive; speed >= 0.');
assert(etaGear > 0 && etaGear <= 1, ...
    'Driveline efficiency must be in (0, 1].');
assert(isfinite(positiveTorqueNm) && positiveTorqueNm >= 0, ...
    'Positive motor torque must be nonnegative and finite.');

out.wheelSpeedRpm = n / ratio;
out.speedMps = 2 * pi * r * out.wheelSpeedRpm / 60;
out.speedKph = 3.6 * out.speedMps;
out.wheelTorqueNm = positiveTorqueNm * ratio * etaGear;
out.tractiveForceN = out.wheelTorqueNm / r;

rho = p.vehicle.airDensityKgM3;
dragCoeff = p.vehicle.dragCoefficient;
A = p.vehicle.frontalAreaM2;
crr = p.vehicle.rollingCoefficient;
assert(all([rho, dragCoeff, A, crr] >= 0), 'Resistance parameters must be nonnegative.');
out.aerodynamicDragN = 0.5 * rho * dragCoeff * A * out.speedMps^2;

out.rollingFlatN = crr * m * g;
out.accelerationFlatMps2 = ...
    (out.tractiveForceN - out.aerodynamicDragN - out.rollingFlatN) / m;

% A 10% road grade is tan(theta)=0.10, NOT theta=10 degrees.
angleRad = atan(p.vehicle.uphillGradePercent / 100);
out.uphillAngleDeg = angleRad * 180 / pi;
out.rollingUphillN = crr * m * g * cos(angleRad);
out.gradeResistanceN = m * g * sin(angleRad);
out.accelerationUphillMps2 = ...
    (out.tractiveForceN - out.aerodynamicDragN - ...
     out.rollingUphillN - out.gradeResistanceN) / m;
end
