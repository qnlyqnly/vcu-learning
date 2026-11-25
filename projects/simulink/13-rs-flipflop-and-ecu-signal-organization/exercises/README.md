# 第13期 · Simulink 动手练习

本文件只覆盖 RS 触发器、Data Type Conversion 和 ECU 子系统整理，不提前加入 Stateflow、故障延时、BSW、CAN 驱动或网关路由。

## A. RS 触发器

1. 打开 MATLAB，在命令窗口输入 simulink 并回车。
2. 选择 Blank Model，新建空白模型。
3. 按 Ctrl+Shift+S，保存为 Issue13_RS_Practice.slx。
4. 在 Library Browser 搜索 RSFlipFlop，拖入画布。若版本模块名称或库位置不同，以本机帮助为准。
5. 放置两个 Pulse Generator、一个 Scope 和一个 Display。
6. Set 脉冲：Amplitude=1、Period=10 s、Pulse width=10%、Phase delay=1 s；若有 Sample time 字段，设为 0.1 s。
7. Reset 脉冲采用相同设置，仅将 Phase delay 改为 6 s。
8. Set 接 S，Reset 接 R，Q 输出分支接 Scope 和 Display。
9. Stop Time 设为 8 s，保存并点击 Run。
10. 双击 Scope 看完整波形；Display 看当前仿真时刻数值。

预期：初始 Q=0；Set 脉冲后 Q=1；S 回到 0 后 Q 保持 1；Reset 脉冲后 Q=0；R 回到 0 后 Q 保持 0。不要把 S、R 同时为 1 的情况当作默认测试，其行为取决于具体模块实现和配置。

## B. Data Type Conversion

1. 放置 Constant、Data Type Conversion 和 Display。
2. Constant 值设为 12.6，依次连接转换模块和 Display。
3. 将 Output data type 先设为 single，应用并运行。
4. 再将目标类型改为 uint8，检查当前版本提供的 Rounding mode 和整数溢出处理选项。
5. 记录输出值与类型。single 是单精度浮点；uint8 是 0～255 的 8 位无符号整数。

## C. ECU 子系统整理

1. 新建空白模型，放置若干 Inport、Data Type Conversion 和 Outport。
2. 使用项目虚构信号清单中的名称作为练习标签。
3. 先选同一 ECU（例如 ABS）的相关模块和需要一起封装的连线。
4. 按 Ctrl+G 创建 Subsystem。
5. 检查子系统输入端口、内部模块、输出端口是否完整。
6. 返回上层，将子系统命名为 ABS。
7. 按相同方式整理 BMS、MCU 等 ECU。
8. 可将这些 ECU 子系统放入名为 CAN 的上层子系统，表达模型内的分类结构。

CAN 只是模型组织命名，不代表已实现报文解析、CAN Pack/Unpack 或真实总线转发。

## 检查清单

- [ ] Set 只接 S，Reset 只接 R，Q 接观察模块。
- [ ] Scope 看随时间变化的波形；Display 看当前数值。
- [ ] 转换模块目标类型符合练习要求。
- [ ] 每个 ECU 子系统只封装对应 ECU 的信号处理模块。
- [ ] 创建后检查 Inport/Outport 数量和连线。
