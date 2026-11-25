function result = organize_ecu_signals(csvPath)
% Group teaching signal metadata by source ECU; no DBC/CAN frame parsing.
if nargin < 1 || isempty(csvPath)
    thisDir = fileparts(mfilename('fullpath'));
    projectDir = fileparts(thisDir);
    csvPath = fullfile(projectDir, 'data', 'ecu_signal_catalog.csv');
end
if ~isfile(csvPath), error('Issue13:CatalogNotFound', 'Catalog not found: %s', csvPath); end
signals = readtable(csvPath, 'TextType', 'string');
required = ["ECU","SignalName","DataType","Direction","Unit","Description"];
missing = setdiff(required, string(signals.Properties.VariableNames));
if ~isempty(missing), error('Issue13:MissingColumns', 'Missing: %s', strjoin(missing, ', ')); end
if numel(unique(signals.SignalName)) ~= height(signals)
    error('Issue13:DuplicateSignalName', 'Signal names must be unique.');
end
allowed = ["boolean","uint8","int16","uint16","single","double"];
if any(~ismember(signals.DataType, allowed))
    error('Issue13:UnknownDataType', 'Unsupported teaching data type.');
end
names = unique(signals.ECU, 'stable'); counts = zeros(numel(names),1);
groups = cell(numel(names),1);
for k = 1:numel(names)
    mask = signals.ECU == names(k);
    groups{k} = signals(mask,:); counts(k) = sum(mask);
end
result.Signals = signals; result.GroupNames = names; result.GroupTables = groups;
result.Summary = table(names, counts, 'VariableNames', {'ECU','SignalCount'});
end
