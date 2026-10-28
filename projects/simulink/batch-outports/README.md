# 第04期 · 一个模块50路输出，怎样批量创建、命名和连接 Outport？

手动拖一个Outport不难。遇到一个模块有几十路输出时，麻烦的是：名字不能漏，源端口不能接错，输出顺序也不能乱。

本期沿着CSDN第04期「Simulink批量创建、命名和连接Outport」继续动手：先看懂5路最小例子，再完成**一个模拟子系统的50路输出 → 50个带名称的根层Outport**，最后故意制造错接，看看检查脚本能否找出来。

全部信号均为虚构教学数据。本期作为教学实验发布，**未在MATLAB/Simulink中运行验证**。下文“预期”均需实际确认。

## 与CSDN同一期，分别解决什么问题？

| 问题 | CSDN第04期的讲解方向 | GitHub配套实践 |
| --- | --- | --- |
| 为什么写脚本 | 几十路输出重复操作的痛点 | 5路入门与50路进阶对照 |
| 批量建模怎么做 | 名称列表、循环、建块和连线 | 保存好的.m文件，一次执行 |
| 名称和端口如何对应 | 不要只凭名字猜线 | 显式sourcePorts(i)→names{i}映射 |
| 怎样确认接对 | 说明检查重点 | 数量、名称、编号、内部来源、外部连线、线名检查 |
| 学完能练什么 | 带读者入门 | 改成8路、交换映射、断线排错和验证记录 |

**CSDN第04期：** [阅读配套文章](https://blog.csdn.net/qian123456wang/article/details/169361654?spm=1001.2014.3001.5502)。

## 本项目的实操特色

- **一个源模块接50个外侧输出。** 顶层只看到一个DemoSource子系统，50路Constant放在源内部，让练习自包含。
- **名称、源序号、根输出序号分开。** 可调整源端口映射，目标根输出固定按配置行顺序编号。
- **先查配置，再创建模块。** 同名模型、重复名称、数量不符、端口越界、已有目标或连线会阻止继续创建。
- **做完还要主动找错。** 检查脚本返回映射表；故障练习帮助理解为什么“有线”不等于“接对”。

## 文件导航

| 文件 | 用途 |
| --- | --- |
| [create_outports.m](create_outports.m) | 5路入门：Constant分别接Outport |
| [check_outports.m](check_outports.m) | 对应的5路名称、来源检查 |
| [batch_config.m](batch_config.m) | 50路配置：模型名、源端口、目标名称、模拟数值 |
| [create_batch_demo.m](create_batch_demo.m) | 一次建模拟源与外侧输出，更新、检查后保存 |
| [connect_demo_outports.m](connect_demo_outports.m) | 外侧批量创建和连线的核心函数 |
| [check_batch_demo.m](check_batch_demo.m) | 检查50路结构并返回映射表 |
| [practice.md](practice.md) | 改数量、交换映射、断线等分级练习 |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | 报错、脚本位置及生成代码常见疑问 |
| [VALIDATION.md](VALIDATION.md) | 验证范围、故障预期与待填写记录 |

## 第一步：先跑5路，理解三个动作

下载本目录所有.m文件到一个**独立练习文件夹**。打开安装了Simulink的MATLAB，把Current Folder切到这个文件夹。不要在实际工程目录里练习。

命令窗口一次执行：

```matlab
create_outports
check_outports
```

预期生成outport_demo.slx：5个Constant分别接Speed、Torque、Voltage、Current、Temperature，检查逐项显示OK。以上是操作预期，不是实测记录。

| 动作 | 对应函数 | 自己观察什么 |
| --- | --- | --- |
| 创建模块 | add_block | 是否出现、位置是否合适 |
| 设置属性 | set_param | 模块名、参数、Port序号 |
| 连接端口 | add_line | 实际来源与目标是否正确 |

模型已存在时停止是预期保护行为。可分别修改两个入门脚本中的model名称，不要为绕过报错直接删除自己的模型。

## 第二步：一个模块的50路输出

不用逐行粘贴长代码。保持本目录所有.m文件位于当前文件夹，一次执行：

```matlab
create_batch_demo
```

预期流程为：校验配置 → 新建outport_batch_demo → 建DemoSource → 创建50个外侧Outport → 按映射接线并命名线 → 更新模型 → 结构检查 → 保存.slx。

双击DemoSource，内部有50组虚构Constant与子系统Outport；返回顶层，外侧Outport接的是**这个子系统的50个输出**。这让实验不依赖外部模型，不代表通信接收或实际业务计算。

| 配置行 / 根Port | 源模块端口 | 外侧名称 | 配置推算值 |
| --- | --- | --- | --- |
| 1 | DemoSource/1 | DemoSignal01 | 101 |
| 2 | DemoSource/2 | DemoSignal02 | 102 |
| 3 | DemoSource/3 | DemoSignal03 | 103 |
| … | … | … | … |
| 50 | DemoSource/50 | DemoSignal50 | 150 |

50路按纵向排列，画布较高，需要缩放和滚动；布局仍待实际检查。

## 第三步：检查端口，而不只是检查名称

```matlab
report = check_batch_demo();
disp(report(1:5, :))
```

检查针对当前内存中的演示模型：

1. 源输出、源内Outport和根输出数量均符合配置。
2. 子系统内第p个模拟源的值、内部Outport的Port和内部连线正确。
3. 外侧名称存在、类型是Outport、根Port等于配置行号。
4. 目标输入确实来自配置指定的源端口，信号线名称也一致。

report.ExpectedValue按配置推算，**不是仿真测量值**。结构检查通过不等于仿真、MIL/SIL或生成代码验证通过。

## 第四步：改配置，理解映射

50路练习的配置集中在batch_config.m：

```matlab
cfg.sourcePorts = 1:50;
cfg.names = arrayfun(@(i) sprintf('DemoSignal%02d', i), ...
    1:50, 'UniformOutput', false);
cfg.values = 101:150;
```

第i行表示：**源模块第sourcePorts(i)个输出，接到名为names{i}、根Port为i的Outport。** 模拟值按源端口序号取值。

若将sourcePorts改成 `[2 1 3:50]`，DemoSignal01的期望值变为102，DemoSignal02变为101。名字没变，来源变了，这就是不能只看名称判断连线的原因。

修改配置不会自动改变旧模型。请使用新的cfg.model名称重新生成；检查旧模型时先恢复生成时配置。详细题目见[practice.md](practice.md)。

## 转到已有模型时，要先确认什么？

核心函数只处理明确的映射，要求：源模块位于模型根层、全部输出一一对应、根层没有旧Outport、源输出尚未接线。它不自动读取未知模块的业务含义，不替换现有连线。

迁移思路前，先确认层级、源输出数量、每路含义、原有连线、类型和单位。Bus、Enabled Subsystem、Model Reference及类型转换需另行设计检查；本例未实现这些场景，不要直接套入真实工程。

## 技术说明与验证边界

文字、配置和教学代码围绕本期独立编写，信号为虚构的DemoSource和DemoSignal01至50，没有使用企业模型、协议或日志。

