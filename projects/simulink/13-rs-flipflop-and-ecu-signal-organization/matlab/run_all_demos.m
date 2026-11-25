function out = run_all_demos()
root=fileparts(fileparts(mfilename('fullpath')));
outDir=fullfile(root,'outputs'); if ~exist(outDir,'dir'), mkdir(outDir); end
out.RS=rs_flipflop_demo();
out.Conversion=data_type_conversion_demo();
out.ECU=organize_ecu_signals(fullfile(root,'data','ecu_signal_catalog.csv'));
writetable(out.RS.Data,fullfile(outDir,'rs_flipflop_results.csv'));
writetable(out.Conversion.Data,fullfile(outDir,'data_type_conversion_results.csv'));
writetable(out.ECU.Summary,fullfile(outDir,'ecu_signal_summary.csv'));
fprintf('Issue 13 demos complete. Results: %s\n',outDir);
end
