function [model, status] = create_composition_model( ...
    ar, compositionNames, compositionIndex)
%CREATE_COMPOSITION_MODEL Create a Simulink Composition model.
%
% Example:
% [model, status] = create_composition_model( ...
%     ar, compositionNames, 1);

narginchk(2, 3);

if nargin < 3
    compositionIndex = 1;
end

% Normalize Composition paths.
if ischar(compositionNames)
    compositionNames = {compositionNames};
elseif isstring(compositionNames)
    compositionNames = cellstr(compositionNames(:));
end

if ~iscellstr(compositionNames) || isempty(compositionNames)
    error('Valid Composition paths are required.');
end

if ~isscalar(compositionIndex) || ...
        compositionIndex ~= floor(compositionIndex) || ...
        compositionIndex < 1 || ...
        compositionIndex > numel(compositionNames)
    error('Composition index is out of range.');
end

compositionPath = compositionNames{compositionIndex};

% Check generated component and Composition model names.
componentPaths = getComponentNames(ar);
allPaths = [componentPaths(:); {compositionPath}];

modelNames = cell(size(allPaths));

for k = 1:numel(allPaths)
    parts = strsplit(allPaths{k}, '/');
    modelNames{k} = parts{end};
end

modelNames = unique(modelNames);
conflicts = {};

for k = 1:numel(modelNames)
    modelName = modelNames{k};

    if isfile([modelName '.slx']) || bdIsLoaded(modelName)
        conflicts{end + 1} = modelName; %#ok<AGROW>
    end
end

if ~isempty(conflicts)
    error(['Existing model name conflict: %s. ' ...
        'Back up or move the existing model files, ' ...
        'or use a clean working folder before creating models.'], ...
        strjoin(conflicts, ', '));
end

% Create the Composition model.
[model, status] = createCompositionAsModel( ...
    ar, compositionPath, ...
    'ModelPeriodicRunnablesAs', 'FunctionCallSubsystem');

if status
    fprintf('Composition model created successfully.\n');
    open_system(model);
else
    warning('Composition model creation was not successful.');
end

end

