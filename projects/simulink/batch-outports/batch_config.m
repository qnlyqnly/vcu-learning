function cfg = batch_config()
% 第04期独立教学配置；名称、端口与数值均为虚构数据。
cfg.model = 'outport_batch_demo';
cfg.source = 'DemoSource';
cfg.sourcePorts = 1:50;
cfg.names = arrayfun(@(i) sprintf('DemoSignal%02d', i), ...
    1:50, 'UniformOutput', false);
cfg.values = 101:150;
% 第 i 项表示：源端口 sourcePorts(i) -> 名为 names{i} 的第 i 个根输出。
% 修改数量时，同步修改 sourcePorts、names、values；生成前校验全部配置。
end
