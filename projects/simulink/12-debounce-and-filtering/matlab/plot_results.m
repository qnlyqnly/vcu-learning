function plot_results(debounce, filtering, outputDir)
% PLOT_RESULTS Plot both demos using base MATLAB graphics.

if nargin < 3 || isempty(outputDir)
    outputDir = pwd;
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

d = debounce.Data;
figure('Name','Scope - Debouncing','Color','w');
stairs(d.TimeS, d.RawInput, 'LineWidth', 1.1);
hold on;
stairs(d.TimeS, d.DebouncedOutput, 'LineWidth', 1.8);
grid on;
xlabel('Time (s)');
ylabel('State (0/1)');
title('Raw switch input and debounced output');
legend('Raw input','Debounced output','Location','best');
ylim([-0.2 1.2]);
saveas(gcf, fullfile(outputDir,'debounce_scope.png'));

f = filtering.Data;
figure('Name','Scope - Low-pass filtering','Color','w');
plot(f.TimeS, f.NoisyInput, 'LineWidth', 0.7);
hold on;
plot(f.TimeS, f.FilteredOutput, 'LineWidth', 1.6);
plot(f.TimeS, f.CleanSignal, '--', 'LineWidth', 1.0);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Noisy input, filtered output and clean reference');
legend('Noisy input','Filtered output','Clean reference','Location','best');
saveas(gcf, fullfile(outputDir,'filter_scope.png'));
end
