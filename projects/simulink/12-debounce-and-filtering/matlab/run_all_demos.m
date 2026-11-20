function results = run_all_demos(makePlots)
% RUN_ALL_DEMOS Run both independent demonstrations and export CSV files.
% Requires base MATLAB only. No Simulink or DSP System Toolbox is required.

if nargin < 1
    makePlots = false;
end

p = demo_parameters();
debounce = run_debounce_demo(p);
filtering = run_filter_demo(p);

thisDir = fileparts(mfilename('fullpath'));
projectDir = fileparts(thisDir);
outputDir = fullfile(projectDir, 'outputs');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

writetable(debounce.Data, fullfile(outputDir, 'debounce_results.csv'));
writetable(filtering.Data, fullfile(outputDir, 'filter_results.csv'));

summary = table( ...
    ["Debounce"; "Low-pass filter"], ...
    [debounce.Summary.OutputTransitionCount; filtering.Summary.Alpha], ...
    [debounce.Summary.FirstTransitionS; filtering.Summary.RawResidualStd], ...
    [debounce.Summary.SecondTransitionS; filtering.Summary.FilteredResidualStd], ...
    'VariableNames', {'Experiment','Metric1','Metric2','Metric3'});
writetable(summary, fullfile(outputDir, 'summary.csv'));

results.Parameters = p;
results.Debounce = debounce;
results.Filtering = filtering;
results.OutputDir = outputDir;

if makePlots
    plot_results(debounce, filtering, outputDir);
end

fprintf('Issue 12 demos completed. CSV files saved to:\n%s\n', outputDir);
fprintf('Debounce transitions: ');
fprintf('%.3f s ', debounce.EdgeTimes);
fprintf('\nFilter residual std: %.4f -> %.4f\n', ...
    filtering.Summary.RawResidualStd, filtering.Summary.FilteredResidualStd);
end
