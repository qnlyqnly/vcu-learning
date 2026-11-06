% Episode 08: fictional CAN channel mapping only.
% Does NOT open or modify an SLX model or communicate with hardware.
% Keep this script and demo_module_inventory.csv in the same folder.

exampleFolder = fileparts(mfilename('fullpath'));
inputFile = fullfile(exampleFolder, 'demo_module_inventory.csv');
inventory = readtable(inputFile, 'TextType', 'string');

% ChannelBefore is the original snapshot; do not overwrite it while mapping.
before = inventory.ChannelBefore;
assert(all(ismember(before, [0 1 2])), ...
    'Only fictional channel numbers 0, 1 and 2 are supported.');

after = before;
after(before == 1) = 2;
after(before == 2) = 1;
changed = (after ~= before);

comparison = table(inventory.ModuleName, before, after, changed, ...
    'VariableNames', {'ModuleName', 'ChannelBefore', ...
    'ChannelAfter', 'Changed'});
disp(comparison);
fprintf('Modules: %d; changed: %d; unchanged: %d.\n', ...
    height(comparison), sum(changed), sum(~changed));

% These assertions check table logic, NOT a model or MIL/SIL result.
assert(all(after(before == 0) == 0), 'CAN0 must stay unchanged.');
assert(all(after(before == 1) == 2), 'Original CAN1 must map to CAN2.');
assert(all(after(before == 2) == 1), 'Original CAN2 must map to CAN1.');
assert(isequal(after, inventory.ChannelExpected), ...
    'Computed channels do not match the CSV expected column.');
fprintf('Table mapping checks passed; model validation was not performed.\n');
