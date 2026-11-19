function results = run_all_examples(makePlot)
%RUN_ALL_EXAMPLES Write 12 teaching traces and a summary to outputs/.
if nargin < 1
    makePlot = false;
end
validateattributes(makePlot, {'logical','numeric'}, ...
    {'scalar','real','finite','binary'}, mfilename, 'makePlot');
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'matlab'), fullfile(root,'examples'));
p = demo_parameters();
cases = {'normal','low_voltage','neg_stuck','permit_removed', ...
    'pos_stuck','pre_stuck','pre_open_stuck','neg_feedback_loss', ...
    'ready_feedback_loss','request_removed','abort_requested','mcu_not_ready'};
outputDir = fullfile(root,'outputs');
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end
n = numel(cases);
results = cell(n,1);
finalState = cell(n,1);
faultCode = cell(n,1);
readyTimeS = NaN(n,1);
fprintf('Issue 11: fictional OFFLINE precharge example\n');
fprintf('I0 = %.3f A, R*C = %.3f s, t95 = %.6f s\n', ...
    p.batteryV/p.resistanceOhm, p.resistanceOhm*p.capacitanceF, ...
    -p.resistanceOhm*p.capacitanceF*log(1-p.completeRatio));
for j = 1:n
    results{j} = simulate_precharge(p,cases{j});
    out = results{j};
    writetable(out.Log, fullfile(outputDir,[cases{j},'.csv']));
    finalState{j} = out.summary.finalState;
    faultCode{j} = out.summary.faultCode;
    readyTimeS(j) = out.summary.readyTimeS;
    fprintf('%-22s %-10s %-24s ready=%.2f s\n', ...
        cases{j}, finalState{j}, faultCode{j}, readyTimeS(j));
end
summary = table(cases', finalState, faultCode, readyTimeS, ...
    'VariableNames', {'Scenario','FinalState','FaultCode','ReadyTimeS'});
writetable(summary, fullfile(outputDir,'summary.csv'));
if logical(makePlot)
    plot_precharge_results(results{1}, outputDir);
end
fprintf('CSV output: %s\n', outputDir);
fprintf('Run run_tests separately to execute the regression assertions.\n');
end
