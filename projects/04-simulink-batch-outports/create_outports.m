%% 第04期：批量创建5组信号源和Outport（原创教学示例）
% 适用场景：先学习批量命名、模块摆放和一对一连线。
% 本脚本会创建一个新的演示模型，不会修改已有工程。
% 运行前请检查当前文件夹/搜索路径中没有同名模型。

clc;

model = 'outport_demo';
signalNames = {'Speed', 'Torque', 'Voltage', 'Current', 'Temperature'};

% 避免覆盖已有模型/未保存的同名模型
if bdIsLoaded(model) || exist([model '.slx'], 'file') == 2
    error('模型 %s 已存在或已加载；请检查后更换 model 名称。', model);
end

new_system(model);
open_system(model);

for i = 1:numel(signalNames)
    name = signalNames{i};
    y = 100 + (i - 1) * 70;
    sourceName = ['Source_' name];

    sourcePath = [model '/' sourceName];
    outportPath = [model '/' name];

    % 使用Constant模拟信号源（不代表真实CAN接收）
    add_block('simulink/Sources/Constant', sourcePath, ...
        'Position', [100 y 150 y+30]);
    set_param(sourcePath, 'Value', num2str(i * 10));

    % 自动创建同名Outport
    add_block('simulink/Sinks/Out1', outportPath, ...
        'Position', [350 y 400 y+30]);

    % 将当前模拟信号源连接到对应的Outport
    add_line(model, [sourceName '/1'], [name '/1'], ...
        'autorouting', 'smart');
end

save_system(model);
fprintf('已生成模型：%s.slx；请检查5组模块名称及连线。\n', model);
