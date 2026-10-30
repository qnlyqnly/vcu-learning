function report = Check_FromGoto_OrphanTags(model)
% From/Goto tag-name screening ONLY. Does not resolve actual tag visibility.
% Example: report = Check_FromGoto_OrphanTags('FromGoto_Demo');
% Reads one already-loaded model; does not load, update, save or change blocks.
% Masked contents, linked-library contents and referenced-model interiors are
% not traversed. Variant coverage depends on find_system/current model state.
% Exact case-sensitive tag names are compared; tags are not trimmed/renamed.

if nargin == 0
    model = bdroot;
end
if isstring(model) && isscalar(model)
    model = char(model);
end
if ~ischar(model) || isempty(model) || ~isrow(model) || ~bdIsLoaded(model)
    error('TagScreen:Model', 'Specify one already-loaded model name.');
end
if ~strcmp(get_param(model, 'Type'), 'block_diagram') || ...
        ~strcmp(get_param(model, 'BlockDiagramType'), 'model')
    error('TagScreen:Model', 'The input must be a model, not a block or library.');
end

fromBlocks = find_system(model, 'LookUnderMasks', 'none', ...
    'FollowLinks', 'off', 'BlockType', 'From');
gotoBlocks = find_system(model, 'LookUnderMasks', 'none', ...
    'FollowLinks', 'off', 'BlockType', 'Goto');
fromBlocks = fromBlocks(:);
gotoBlocks = gotoBlocks(:);
fromTags = readTags(fromBlocks);
gotoTags = readTags(gotoBlocks);
tags = unique([fromTags; gotoTags], 'stable');
n = numel(tags);

fromCount = zeros(n, 1);
gotoCount = zeros(n, 1);
fromPaths = cell(n, 1);
gotoPaths = cell(n, 1);
visibility = cell(n, 1);
finding = cell(n, 1);
isCandidate = false(n, 1);
for i = 1:n
    f = strcmp(fromTags, tags{i});
    g = strcmp(gotoTags, tags{i});
    fromCount(i) = sum(f);
    gotoCount(i) = sum(g);
    fromPaths{i} = strjoin(fromBlocks(f), ' | ');
    gotoPaths{i} = strjoin(gotoBlocks(g), ' | ');
    matchedGoto = gotoBlocks(g);
    scopes = cell(numel(matchedGoto), 1);
    for j = 1:numel(matchedGoto)
        scopes{j} = get_param(matchedGoto{j}, 'TagVisibility');
    end
    visibility{i} = strjoin(scopes, ' | ');
    reasons = {};
    if fromCount(i) > 0 && gotoCount(i) == 0
        reasons{end+1} = 'FROM_WITHOUT_NAME_MATCH'; %#ok<AGROW>
    end
    if gotoCount(i) > 0 && fromCount(i) == 0
        reasons{end+1} = 'GOTO_WITHOUT_NAME_MATCH'; %#ok<AGROW>
    end
    if gotoCount(i) > 1
        reasons{end+1} = 'DUPLICATE_GOTO_NAME'; %#ok<AGROW>
    end
    isCandidate(i) = ~isempty(reasons);
    if isempty(reasons)
        finding{i} = 'NAME_MATCH_ONLY';
    else
        finding{i} = strjoin(reasons, '; ');
    end
end
report = table(tags, fromCount, gotoCount, fromPaths, gotoPaths, ...
    visibility, finding, isCandidate, 'VariableNames', ...
    {'Tag', 'FromCount', 'GotoCount', 'FromPaths', 'GotoPaths', ...
    'GotoVisibility', 'Finding', 'IsCandidate'});
if n == 0
    fprintf('No From/Goto blocks found within the stated search coverage.\n');
else
    disp(report);
end
fprintf('Name screening only: %d tag(s), %d candidate row(s).\n', ...
    n, sum(isCandidate));
fprintf('No local/scoped/global visibility or functional correctness guarantee.\n');
end

function tags = readTags(blocks)
tags = cell(numel(blocks), 1);
for k = 1:numel(blocks)
    tags{k} = get_param(blocks{k}, 'GotoTag');
end
end
