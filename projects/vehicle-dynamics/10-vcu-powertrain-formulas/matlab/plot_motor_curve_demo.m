function imagePath = plot_motor_curve_demo(p)
%PLOT_MOTOR_CURVE_DEMO Reproducible illustrative motor torque-speed graph.
% Uses a separate fictional motor envelope, not a production map.

curveValues = {p.motor.curveMaxSpeedRpm, ...
    p.motor.curveMaxTorqueNm, p.motor.curveMaxPowerKW};
for k = 1:numel(curveValues)
    validateattributes(curveValues{k}, {'numeric'}, ...
        {'real','finite','scalar','positive'}, mfilename);
end

n = linspace(0, p.motor.curveMaxSpeedRpm, 301);
Tmax = p.motor.curveMaxTorqueNm;
Pmax = p.motor.curveMaxPowerKW;
baseRpm = 9550 * Pmax / Tmax;

T = Tmax * ones(size(n));
positive = n > 0;
T(positive) = min(Tmax, 9550 * Pmax ./ n(positive));

fig = figure('Color','w', 'Visible','off');
cleanupFigure = onCleanup(@() close(fig)); %#ok<NASGU>
plot(n, T, 'b-', 'LineWidth', 2.4); hold on;
plot([baseRpm, baseRpm], [0, Tmax], 'k--', 'LineWidth', 1.2);
grid on;
xlabel('Motor speed (rpm)');
ylabel('Allowed motor torque (N*m)');
title('Illustrative motor torque-speed limit (not production data)');
legend('Torque limit','Base speed','Location','northeast');
axis([0, p.motor.curveMaxSpeedRpm, 0, 1.15*Tmax]);

projectRoot = fileparts(fileparts(mfilename('fullpath')));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end
imagePath = fullfile(figDir, 'motor_torque_speed_generated.png');
print(fig, imagePath, '-dpng', '-r160');
end
