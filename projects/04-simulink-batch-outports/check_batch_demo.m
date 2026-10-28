function report = check_batch_demo()
% 结构检查：数量、名称、端口序号、连线来源、模拟值和信号线名称。
% 检查当前内存中的模型；不等同于仿真、MIL/SIL或生成代码验证。
cfg = batch_config();
if ~bdIsLoaded(cfg.model)
    if exist([cfg.model '.slx'], 'file') ~= 2
        error('episode04:MissingModel', '请先运行 create_batch_demo。');
    end
    load_system(cfg.model);
end
n = numel(cfg.names);
assert(n > 0 && numel(cfg.sourcePorts) == n && numel(cfg.values) == n, ...
    'episode04:Config', '配置长度不一致。');
assert(isequal(sort(cfg.sourcePorts(:))', 1:n), ...
    'episode04:Config', '源端口映射不是1:N的排列。');
source = [cfg.model '/' cfg.source];
assert(getSimulinkBlockHandle(source) ~= -1, ...
    'episode04:Source', '源模块缺失。');
assert(strcmp(get_param(source, 'BlockType'), 'SubSystem'), ...
    'episode04:SourceType', '源模块应为模拟子系统。');
sourceHandles = get_param(source, 'PortHandles');
roots = find_system(cfg.model, 'SearchDepth', 1, 'BlockType', 'Outport');
inner = find_system(source, 'SearchDepth', 1, 'BlockType', 'Outport');
assert(numel(roots) == n && numel(inner) == n && numel(sourceHandles.Outport) == n, ...
    'episode04:Count', '根输出/源输出数量与配置不一致。');

for p = 1:n
    constant = [source '/Value' num2str(p)];
    sourceOut = [source '/SourcePort' num2str(p)];
    assert(getSimulinkBlockHandle(constant) ~= -1 && ...
        getSimulinkBlockHandle(sourceOut) ~= -1, ...
        'episode04:InnerMissing', '模拟源内部模块缺失。');
    assert(strcmp(get_param(constant, 'BlockType'), 'Constant') && ...
        strcmp(get_param(sourceOut, 'BlockType'), 'Outport'), ...
        'episode04:InnerType', '模拟源内部模块类型不符。');
    assert(str2double(get_param(sourceOut, 'Port')) == p && ...
        str2double(get_param(constant, 'Value')) == cfg.values(p), ...
        'episode04:InnerValue', '源端口序号或模拟数值不符。');
    a = get_param(constant, 'PortHandles');
    b = get_param(sourceOut, 'PortHandles');
    assertSource(b.Inport(1), a.Outport(1), sourceOut);
end

expected = zeros(n, 1);
for i = 1:n
    target = [cfg.model '/' cfg.names{i}];
    assert(getSimulinkBlockHandle(target) ~= -1, ...
        'episode04:MissingOutport', '目标 Outport 缺失：%s', target);
    assert(strcmp(get_param(target, 'BlockType'), 'Outport'), ...
        'episode04:Type', '目标模块类型不是 Outport。');
    assert(str2double(get_param(target, 'Port')) == i, ...
        'episode04:Order', '根输出 Port 序号不符：%s', target);
    b = get_param(target, 'PortHandles');
    line = assertSource(b.Inport(1), sourceHandles.Outport(cfg.sourcePorts(i)), target);
    assert(strcmp(get_param(line, 'Name'), cfg.names{i}), ...
        'episode04:LineName', '信号线名称不符：%s', target);
    expected(i) = cfg.values(cfg.sourcePorts(i));
end
report = table((1:n)', cfg.sourcePorts(:), cfg.names(:), expected, ...
    'VariableNames', {'RootPort', 'SourcePort', 'OutportName', 'ExpectedValue'});
disp(report);
fprintf('结构检查通过：%d路。ExpectedValue为配置推算值，不是仿真实测值。\n', n);
end

function line = assertSource(destinationPort, expectedSource, label)
line = get_param(destinationPort, 'Line');
assert(line ~= -1, 'episode04:Unconnected', '存在未连线端口：%s', label);
assert(get_param(line, 'SrcPortHandle') == expectedSource, ...
    'episode04:WrongSource', '连线来源不符：%s', label);
end
