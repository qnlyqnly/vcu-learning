%% 第04期：检查演示模型中的5个Outport是否接对
% 请先运行 create_outports.m。仅检查结构与连线，不等于仿真验证。

model = 'outport_demo';
signalNames = {'Speed', 'Torque', 'Voltage', 'Current', 'Temperature'};

if ~bdIsLoaded(model)
    if exist([model '.slx'], 'file') ~= 2
        error('找不到 %s.slx；请先运行 create_outports.m。', model);
    end
    load_system(model);
end

for i = 1:numel(signalNames)
    name = signalNames{i};
    sourcePath = [model '/Source_' name];
    outportPath = [model '/' name];

    if getSimulinkBlockHandle(sourcePath) == -1
        error('缺少信号源：%s', sourcePath);
    end
    if getSimulinkBlockHandle(outportPath) == -1
        error('缺少Outport：%s', outportPath);
    end
    if ~strcmp(get_param(outportPath, 'BlockType'), 'Outport')
        error('%s 不是Outport模块。', outportPath);
    end

    sourceHandles = get_param(sourcePath, 'PortHandles');
    outportHandles = get_param(outportPath, 'PortHandles');
    lineHandle = get_param(outportHandles.Inport(1), 'Line');
    if lineHandle == -1
        error('Outport %s 尚未连接。', name);
    end
    actualSource = get_param(lineHandle, 'SrcPortHandle');
    if actualSource ~= sourceHandles.Outport(1)
        error('Outport %s 的信号源连接不正确。', name);
    end
    fprintf('OK：%s ← Source_%s\n', name, name);
end

fprintf('结构检查结束：%d 路名称与连接关系符合预期。\n', numel(signalNames));
fprintf('提醒：这不是MIL/SIL或功能仿真结果。\n');
