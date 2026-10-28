# 第04期动手练习：从“创建了”到“接对了”

配合CSDN第04期Outport批量建模主题使用。先写预期，再运行和记录。下文均为待验证预期。

## 第1关：5路入门，分清四件事

运行create_outports和check_outports。选Speed这一组，分别查看模块名称、根层Port参数、实际连线来源和信号线名称。

| 检查项 | 为什么分开看 |
| --- | --- |
| 模块名称 | 名字叫Speed不证明来源正确 |
| 根层Port | 它决定输出顺序 |
| 实际来源 | 确认真正接的是谁 |
| 线名称 | 它不等于模块名称；入门脚本未单独设置 |

思考：Source_Speed误接Torque时，两个名称都没变，为什么仍然是错的？

判断依据：名称检查确认“谁存在”，来源检查确认“接的是谁”。

## 第2关：50路，先预测再执行

原始配置运行create_batch_demo。顶层预期1个DemoSource和50个Outport；源内部预期50个Constant和50个Outport。

```matlab
report = check_batch_demo();
disp(report([1 2 25 50], :))
```

先写下这4行的名字、源端口、根Port和期望值，再看报告。ExpectedValue为配置推算，不是仿真结果。

## 第3关：改成8路，只改一处配置

仅替换batch_config.m中相应字段，其余保持原样：

```matlab
cfg.model = 'outport_batch_demo_8';
cfg.sourcePorts = 1:8;
cfg.names = arrayfun(@(i) sprintf('DemoSignal%02d', i), ...
    1:8, 'UniformOutput', false);
cfg.values = 101:108;
```

再次运行create_batch_demo。检查源输出数、根输出数和报告行数是否都是8。

换模型名是因为生成函数拒绝覆盖同名模型；无需修改生成函数和检查函数里的名单。

## 第4关：换来源，名字不变

在8路配置基础上，把模型名改为outport_batch_demo_swap，修改：

```matlab
cfg.sourcePorts = [2 1 3:8];
```

先判断DemoSignal01期望值是101还是102，再生成并查看报告。

判断依据：配置第1项根Port仍为1，但接源Port2，因此期望值是102。这只是映射练习，不表示实际接口可随意交换。

## 第5关：主动断开一条外侧线

保持配置，先运行check_batch_demo建立基线。手动删一条外侧线后再检查。

预期：episode04:Unconnected，指出未接线目标。记录真实报错后按映射手动接回，再检查。

想重新生成时使用新模型名；不要以删除自己的模型来绕过保护。

## 第6关：两条外侧线交换来源

配置不变，手动交换两路来源，目标名称不变，再运行检查。

预期：episode04:WrongSource，说明不是仅检查“有线”。恢复原映射后重新检查。

不要同时修改配置来迎合错误接线，那样会把错误变成新的检查基准。

## 第7关：编号和线名也能错

每次只造一个错误，完成后恢复基线：

- 交换两个根Outport的Port编号：预期episode04:Order。
- 只改顶层某条信号线名称：预期episode04:LineName。
- 改源内部某个Constant值：预期episode04:InnerValue。

名称、来源、根输出编号和线名是不同检查项。名字对了不能替代其他检查。

## 第8关：让配置先报错

每次用新模型名，分别尝试重复名称、漏写源端口、把端口改成0或99。

预期：创建模型前拒绝非法配置。记录是否确实在创建前停止，之后恢复合法配置。

## 用自己的话写结论

1. add_block、set_param、add_line各做什么？
2. sourcePorts(i)和根Outport的Port=i必须相同吗？
3. 配置推算、结构检查、模型更新、仿真和生成代码有什么区别？
4. 为什么脚本不报错不能直接证明实际控制功能正确？

把实际版本、结果和报错填到[VALIDATION.md](VALIDATION.md)，再决定哪些实测经验可以写回CSDN第04期。
