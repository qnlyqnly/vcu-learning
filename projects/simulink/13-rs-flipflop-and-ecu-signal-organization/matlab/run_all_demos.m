function results = run_all_demos()
% Run independent base-MATLAB teaching examples; does not execute Simulink.
thisDir = fileparts(mfilename('fullpath')); projectDir = fileparts(thisDir);
outputDir = fullfile(projectDir, 'outputs');
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
rs = rs_flipflop_demo();
conversion = data_type_conversion_demo();
ecu = organize_ecu_signals(fullfile(projectDir,'data','ecu_signal_catalog.csv'));
writetable(rs.Data, fullfile(outputDir,'rs_flipflop_results.csv'));
writetable(conversion.Data, fullfile(outputDir,'data_type_conversion_results.csv'));
writetable(ecu.Summary, fullfile(outputDir,'ecu_signal_summary.csv'));
results.RS = rs; results.Conversion = conversion; results.ECU = ecu;
results.OutputDir = outputDir;
fprintf('Issue 13 base-MATLAB demos completed.\n');
end
