function create_batch_demo()
% 新建一个含50路输出的模拟子系统，再在外侧批量创建、命名、连接 Outport。
% 在 MATLAB 当前文件夹运行 create_batch_demo；不修改已有工程。
cfg = batch_config();
n = numel(cfg.names);
if ~ischar(cfg.model) || ~isvarname(cfg.model) || ...
        ~ischar(cfg.source) || ~isvarname(cfg.source)
    error('episode04:Config', '模型和源模块名称必须为合法简单名称。');
end
if ~iscell(cfg.names) || ~isvector(cfg.names) || n == 0 || ...
        ~all(cellfun(@(s) ischar(s) && isrow(s) && isvarname(s), cfg.names)) || ...
        numel(unique(cfg.names)) ~= n || any(strcmp(cfg.names, cfg.source))
    error('episode04:Config', '目标名称必须合法、唯一且不能与源模块同名。');
end
if ~isnumeric(cfg.sourcePorts) || ~isvector(cfg.sourcePorts) || ...
        numel(cfg.sourcePorts) ~= n || ...
        ~isequal(sort(cfg.sourcePorts(:))', 1:n) || ...
        ~isnumeric(cfg.values) || ~isvector(cfg.values) || ...
        numel(cfg.values) ~= n || any(~isfinite(cfg.values)) || ~isreal(cfg.values)
    error('episode04:Config', '端口须为1:N的排列，数值须为N个有限实数。');
end
if bdIsLoaded(cfg.model) || exist([cfg.model '.slx'], 'file') ~= 0 || ...
        exist([cfg.model '.mdl'], 'file') ~= 0
    error('episode04:Exists', '同名模型已存在或已加载，请在 batch_config 中更换名称。');
end

new_system(cfg.model);
open_system(cfg.model);
sourcePath = [cfg.model '/' cfg.source];
% built-in/SubSystem 创建空子系统，避免复制带默认 In1/Out1 的模板。
add_block('built-in/SubSystem', sourcePath, ...
    'Position', [100 40 350 40+n*65]);
for p = 1:n
    y = 60 + (p - 1) * 65;
    constant = [sourcePath '/Value' num2str(p)];
    output = [sourcePath '/SourcePort' num2str(p)];
    add_block('simulink/Sources/Constant', constant, ...
        'Value', num2str(cfg.values(p), 17), ...
        'Position', [80 y 160 y+25]);
    add_block('simulink/Sinks/Out1', output, 'Port', num2str(p), ...
        'Position', [300 y 330 y+20]);
    a = get_param(constant, 'PortHandles');
    b = get_param(output, 'PortHandles');
    add_line(sourcePath, a.Outport(1), b.Inport(1), 'autorouting', 'on');
end
connect_demo_outports(cfg.model, cfg.source, cfg.sourcePorts, cfg.names);
% 更新模型用于发现建模错误；这不是MIL/SIL或代码生成测试。
set_param(cfg.model, 'SimulationCommand', 'update');
check_batch_demo();
save_system(cfg.model);
fprintf('已保存 %s.slx；请继续手动检查布局，并填写验证记录。\n', cfg.model);
% 出错时保留演示模型供排查，不自动关闭，也不自动删除或覆盖任何文件。
end
