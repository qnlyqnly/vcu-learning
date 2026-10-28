function connect_demo_outports(model, sourceName, sourcePorts, names)
% 为独立教学模型中指定的源模块创建一组根层 Outport。
% 本函数不识别业务含义，不删除旧块、不自动重命名、不替换已有连线。
% sourcePorts(i) -> names{i}，根层 Outport 的 Port 固定为 i。

if ~ischar(model) || ~isvarname(model) || ~bdIsLoaded(model)
    error('episode04:Model', '请传入已加载的独立演示模型名称。');
end
if ~ischar(sourceName) || ~isvarname(sourceName)
    error('episode04:Source', 'sourceName 必须是直接位于模型根层的简单模块名。');
end
if ~iscell(names) || isempty(names) || ~isvector(names) || ...
        ~all(cellfun(@(s) ischar(s) && isrow(s) && isvarname(s), names))
    error('episode04:Names', 'names 必须是非空且不重复的合法名称 cell 列表。');
end
if numel(unique(names)) ~= numel(names) || any(strcmp(names, sourceName))
    error('episode04:Duplicate', '目标名称重复或与源模块名称冲突。');
end
if ~isnumeric(sourcePorts) || ~isvector(sourcePorts) || ...
        numel(sourcePorts) ~= numel(names) || ...
        any(~isfinite(sourcePorts)) || any(sourcePorts < 1) || ...
        any(sourcePorts ~= fix(sourcePorts)) || ...
        numel(unique(sourcePorts)) ~= numel(sourcePorts)
    error('episode04:Mapping', '源端口必须是与名称一一对应的正整数，且不能重复。');
end

sourcePath = [model '/' sourceName];
if getSimulinkBlockHandle(sourcePath) == -1
    error('episode04:MissingSource', '找不到源模块：%s', sourcePath);
end
ph = get_param(sourcePath, 'PortHandles');
if numel(ph.Outport) ~= numel(names) || ...
        ~isequal(sort(sourcePorts(:))', 1:numel(ph.Outport))
    error('episode04:PortCount', '本练习要求源模块全部输出与配置一一对应。');
end
existing = find_system(model, 'SearchDepth', 1, 'BlockType', 'Outport');
if ~isempty(existing)
    error('episode04:ExistingOutports', '根层已有 Outport，停止创建；不会改动原有输出。');
end
% 所有碰撞和已有连线检查先完成，再开始创建任何目标模块。
for i = 1:numel(names)
    if getSimulinkBlockHandle([model '/' names{i}]) ~= -1
        error('episode04:Collision', '已有同名模块：%s', names{i});
    end
    if get_param(ph.Outport(sourcePorts(i)), 'Line') ~= -1
        error('episode04:Connected', '源端口 %d 已连线，本练习不替换已有线。', sourcePorts(i));
    end
end

for i = 1:numel(names)
    y = 60 + (i - 1) * 65;
    target = [model '/' names{i}];
    add_block('simulink/Sinks/Out1', target, ...
        'Port', num2str(i), 'Position', [650 y 680 y+20]);
    targetPorts = get_param(target, 'PortHandles');
    line = add_line(model, ph.Outport(sourcePorts(i)), ...
        targetPorts.Inport(1), 'autorouting', 'on');
    set_param(line, 'Name', names{i});
end
end
