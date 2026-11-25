# VCU Learning Lab · 控制学习与实验

> 公开的个人原创 VCU 技术学习项目｜以独立设计的小实验记录 CAN 通信、DBC 和 VCU 相关学习过程。不是企业量产项目，不使用内部资料。

欢迎来到 `vcu-learning`。这里用**大白话说明 + 能自己运行的例子 + 清楚的限制**，记录从通信基础走向汽车电子与整车控制的实践。

## 按期数浏览 · 总目录

按 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 阅读。每期的文章、练习和验证状态集中列在下面。

| 期数 | 主题 | CSDN 文章 | GitHub 练习 | 验证状态 |
| --- | --- | --- | --- | --- |
| **01** | Excel 通信矩阵批量生成 DBC | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/168146222) | [代码与 Excel 模板](projects/01-excel-to-dbc/) | 本地 8 项测试通过；图形工具与台架待验证 |
| **02** | CAN 报文与 DBC 有什么区别 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/167691097?spm=1001.2014.3001.5502) | [DBC 示例与手工解析](projects/02-can-dbc-basics/) | 已人工核对；软件导入与解析待验证 |
| **03** | 通信矩阵：分清独立信号与高低字节 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/168873109?spm=1001.2014.3001.5501) | [信号边界与位运算练习](projects/can-dbc/signal-boundaries/) | 位运算核对 3/3；DBC 加载待验证 |
| **04** | Simulink：一个模块 50 路 Outport，批量创建、命名和连接 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/169361654?spm=1001.2014.3001.5502) | [批量建模与排错练习](projects/simulink/batch-outports/) | 已人工阅读代码；MATLAB/Simulink 实测待完成 |
| **05** | Simulink：CAN Pack、CAN Unpack、From 和 Goto | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/169555029) | [CAN收发与信号路由练习](projects/simulink/05-can-pack-unpack-routing/) | 字节计算已核对，MATLAB与Pack/Unpack未实测 |
| **06** | CAN 总线基础、终端电阻与示波器 / ZCANPRO / MeCa | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/170033630) | [CAN 总线与工具练习](projects/can-tools/06-can-bus-tools-practice/) | 静态核对与离线示例检查；工具和硬件未实测 |
| **07** | Vector DaVinci：SWC、Interface、Port与组件连接 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/170187339) | [两组件车速结构练习](projects/autosar/07-davinci-toolchain/) | 静态文件已核对；DaVinci搭建与运行待验证 |
| **08** | Simulink：CAN 通道批量修改 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/170195987) | [通道映射与修改核对练习](projects/simulink/08-can-channel-batch-edit/) | 静态核对完成；MATLAB执行与模型验证待完成 |
| **09** | AUTOSAR：Port初始值、AccessPoints、TypeMapping与ARXML模型生成 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/170491918?spm=1001.2014.3001.5501) | [ARXML导入与Composition模型练习](projects/autosar/09-arxml-to-simulink-composition/) | 脚本代码审阅完成；MATLAB/DaVinci实测待完成 |
| **10** | 新能源汽车VCU动力系统常用计算公式：电池功率、扭矩与整车加速度 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/170698701) | [MATLAB动力系统公式练习](projects/vehicle-dynamics/10-vcu-powertrain-formulas/) | 公式数值已独立核对；MATLAB未实测，MIL/实车未验证 |
| **11** | VCU高压上电控制：上电请求、预充与主继电器闭合 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/171017310) | [高压预充离线仿真及故障测试](projects/vehicle-control/11-vcu-hv-precharge/) | 5个.m静态检查完成；Python独立参考14组通过；MATLAB/Simulink未实测 |
| **12** | 汽车电子：Simulink 消抖与滤波对比实战 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/171094467?spm=1001.2014.3001.5501) | [MATLAB实验、测试与配图](projects/simulink/12-debounce-and-filtering/) | Python参考检查通过；MATLAB/Simulink/Stateflow待实测 |
| **13** | Simulink 模型开发：RS触发器与多ECU CAN信号转发 | [阅读文章](https://blog.csdn.net/qian123456wang/article/details/171372527) | [RS参考、ECU信号整理与八张配图](projects/simulink/13-rs-flipflop-and-ecu-signal-organization/) | Python独立参考与CSV检查通过；MATLAB/Simulink未实测 |


## 新手推荐顺序

1. **第01期：把表变成文件。** 学会填写通信矩阵，观察脚本如何生成 DBC。
2. **第02期：把定义和报文对应起来。** 对照 DBC 与虚构报文，练习手工解析。
3. **第03期：把信号边界分清楚。** 理解独立信号、跨字节数值和起始位，完成位运算核对。
4. **第04期：动手做 Simulink 建模。** 从 5 路入门到 50 路输出，练习批量命名、端口映射、连线检查和排错。
5. **第05期：看懂 CAN 收发与信号路由。** 区分 Pack、Unpack、From 和 Goto。
6. **第06期：认识 CAN 总线与观察工具。** 先看拓扑和波形，再练习报文记录与内部变量观察。
7. **第07期：连接两个AUTOSAR软件组件。** 对照接口、P/R端口和Composition内的组件实例。
8. **第08期：批量修改CAN通道。** 对照手动、MATLAB和AI三种方法，先保存原值，再核对CAN1/CAN2交换。
9. **第09期：从ARXML生成Composition模型。** 核对数据访问、初始值与类型映射，再列出Composition路径并创建初始模型。

10. **第10期：从电池功率算到整车加速度。** 通过虚构数据练习BMS功率限扭、轮端驱动力、坡度和回馈换算，执行状态见验证记录。
11. **第11期：用状态和反馈检查高压上电。** 用独立RC参数观察主负、预充、主正的命令/反馈，练习预充超时、拒动和中止；先读验证边界再运行MATLAB参考脚本。
12. **第12期：分清消抖与滤波。** 用开关触点抖动和连续数值噪声两个独立实验，比较状态确认与低通滤波；Python参考检查已执行，MATLAB/Simulink仍待实测。

13. **第13期：理解RS状态保持并整理多ECU信号。** 对照八张原创教学示意图，完成基础MATLAB参考与模型内信号分类练习；真实CAN报文转发不在本期范围。

## 按技术方向浏览

- [CAN 与 DBC](projects/can-dbc/)：第01—03期的通信基础与信号整理练习。
- [Simulink](projects/simulink/)：第04期起的建模、端口连接与结构检查练习，以及第12期消抖与滤波、第13期RS触发器与ECU信号整理练习。

- [CAN 工具](projects/can-tools/)：第06期起的终端电阻、示波器、报文采集与变量观察练习。

- [AUTOSAR / DaVinci](projects/autosar/)：第07期的组件连接与第09期的ARXML导入、Composition模型生成练习。

- [车辆动力学 / 功率扭矩计算](projects/vehicle-dynamics/)：第10期的原创MATLAB计算、曲线与练习。

- [VCU控制策略](projects/vehicle-control/)：第11期的高压上电、预充状态机、反馈与故障测试练习。

## 后续计划（不代表已经完成）

- 在 CANdb++ 中检查生成 DBC 的报文、信号、起始位与比例系数。
- 增加针对字节序的独立学习案例。
- 建立独立的模拟 CAN 发送/接收验证实验。
- 逐步增加 MATLAB/Simulink 的原创状态机或诊断练习。

## 公开与保密约定

- 所有现有报文名称、信号和数值均为独立设计的模拟数据。
- 不上传公司/客户协议、标定参数、内部模型、日志、截图或付费课程源码。
- 不将本仓库视为真实控制器通信协议或可以直接投入量产的工具。
- **新增内容公开前须经过审核。**本仓库目前公开展示，暂未添加开源许可证。代码仅供学习参考，具体使用和再分发权限以未来的许可证为准。


