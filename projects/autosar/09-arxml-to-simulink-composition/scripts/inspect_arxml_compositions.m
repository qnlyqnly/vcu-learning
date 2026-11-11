function [ar, compositionNames] = inspect_arxml_compositions(arxmlFiles)
%INSPECT_ARXML_COMPOSITIONS Import ARXML files and list Composition paths.
%
% Example:
% [ar, names] = inspect_arxml_compositions( ...
%     'VCU_Lab_Composition.arxml');
%
% Multiple dependent files:
% [ar, names] = inspect_arxml_compositions({ ...
%     'VCU_Lab_Composition.arxml', ...
%     'VCU_Lab_DataTypes.arxml'});

narginchk(1, 1);

% Normalize input to a cell array of character vectors.
if ischar(arxmlFiles)
    arxmlFiles = {arxmlFiles};
elseif isstring(arxmlFiles)
    arxmlFiles = cellstr(arxmlFiles(:));
elseif ~iscellstr(arxmlFiles)
    error('ARXML input must be a filename or a cell array of filenames.');
end

if isempty(arxmlFiles)
    error('At least one ARXML filename is required.');
end

% Check that all input files exist.
for k = 1:numel(arxmlFiles)
    if ~isfile(arxmlFiles{k})
        error('ARXML file not found: %s', arxmlFiles{k});
    end
end

% Import AUTOSAR XML descriptions.
ar = arxml.importer(arxmlFiles);

% Retrieve Composition paths.
compositionNames = getComponentNames(ar, 'Composition');

if isempty(compositionNames)
    warning('No AUTOSAR Composition was found in the imported files.');
    return;
end

fprintf('Found %d Composition(s):\n', numel(compositionNames));

for k = 1:numel(compositionNames)
    fprintf('%d. %s\n', k, compositionNames{k});
end

end

