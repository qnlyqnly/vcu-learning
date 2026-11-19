function paths = plot_precharge_results(out, outputDir)
%PLOT_PRECHARGE_RESULTS Actual MATLAB plots, separate from UI mockups.
if nargin < 2
    outputDir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'outputs');
end
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end
L = out.Log;
fig = figure('Color','w','Name','Issue 11 - offline precharge','Visible','off');
cleanupFigure = onCleanup(@() close(fig)); %#ok<NASGU>
subplot(3,1,1);
plot(L.TimeS,L.UbattV,'k--',L.TimeS,L.UbusV,'b-','LineWidth',1.5);
hold on;
plot(L.TimeS,out.parameters.completeRatio*L.UbattV,'r:');
grid on;
ylabel('Voltage (V)');
legend('Ubatt','Ubus','Threshold','Location','southeast');
title(['Offline teaching simulation: ',out.scenario],'Interpreter','none');
subplot(3,1,2);
plot(L.TimeS,L.IpreA,'b-','LineWidth',1.5);
grid on;
ylabel('Ipre (A)');
subplot(3,1,3);
stairs(L.TimeS,L.StateCode,'b-','LineWidth',1.5);
hold on;
stairs(L.TimeS,4*double(L.HvReady),'g--');
grid on;
ylabel('State code');
xlabel('Time (s)');
legend('State 0..5','4 x HvReady','Location','southeast');
paths.voltage = fullfile(outputDir,[out.scenario,'_voltage.png']);
print(fig,paths.voltage,'-dpng','-r160');

fig2 = figure('Color','w','Name','Command and feedback','Visible','off');
cleanupTiming = onCleanup(@() close(fig2)); %#ok<NASGU>
cmdNames = {'MainNegCmd','PrechargeCmd','MainPosCmd'};
fbNames = {'MainNegFb','PrechargeFb','MainPosFb'};
for j = 1:3
    subplot(3,1,j);
    stairs(L.TimeS,double(L.(cmdNames{j})),'b-','LineWidth',1.5);
    hold on;
    stairs(L.TimeS,double(L.(fbNames{j})),'r--','LineWidth',1.5);
    grid on;
    ylim([-0.1,1.2]);
    ylabel('0 / 1');
    legend(cmdNames{j},fbNames{j},'Interpreter','none','Location','southeast');
end
xlabel('Time (s)');
paths.timing = fullfile(outputDir,[out.scenario,'_timing.png']);
print(fig2,paths.timing,'-dpng','-r160');
end
