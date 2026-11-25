# 第13期 · Simulink 动手练习

本文件只覆盖 RS 触发器、Data Type Conversion 和 ECU 子系统整理，不提前加入 Stateflow、故障延时、BSW、CAN 驱动或网关路由。

## A. RS 触发器

1. 打开 MATLAB，在命令窗口输入 simulink 并回车。
2. 选择 Blank Model，新建空白模型。
3. 按 Ctrl+Shift+S，保存为 Issue13_RS_Practice.slx。
4. 打开 Library Browser，搜索官方模块 `S-R Flip-Flop`（Simulink Extras / Flip Flops），拖入画布。图中的 `RSFlipFlop` 是教学显示名，不保证能按这个名字搜索到。双击模块，确认 Initial condition (state of Q)=0，点击 OK。
5. 放置两个 Pulse Generator、两个 Data Type Conversion、一个 Scope、一个 Display 和一个 Terminator。两个转换模块的 Output data type 均设为 boolean，点击 OK，使 S/R 输入类型一致。官方模块可能还有 `!Q` 输出，将它接 Terminator；按本机端口文字识别 Q、S、R，不照抄示意图的上下顺序。
6. 双击第一个 Pulse Generator，将 Pulse type 设为 Time based、Time (t) 设为 Use simulation time、Amplitude=1、Period=10 s、Pulse width=10%、Phase delay=1 s，点击 OK。将模块重命名为 SetPulse。本配置的周期和延迟单位为秒，不填 Sample based 模式的样本数。
7. 第二个脉冲采用相同配置，仅将 Phase delay 改为 6 s，命名为 ResetPulse，点击 OK。
8. SetPulse 经第一个 boolean 转换接 S，ResetPulse 经第二个转换接 R；从 Q 拉线到 Scope，再从 Q 连线上创建分支接 Display。Scope 默认只看 Q；若希望同时观察图03的 S/R/Q，双击 Scope，在配置属性中将输入端口数设为 3，再将 S、R、Q 分别接三路输入（入口名称以本机版本为准）。
9. 按 Ctrl+E 打开 Configuration Parameters，在 Solver 页设 Type=Fixed-step、Solver=discrete (no continuous states)、Fixed-step size=0.1、Start time=0、Stop time=10，点击 Apply 后 OK。按 Ctrl+S 保存，再点击 Run。
10. 仿真完成后双击 Scope，点击 Autoscale 适配坐标范围，检查 1 s 置位与 6 s 复位。Display 看当前仿真时刻数值，10 s 结束应为 0。需要中止时点击模型 Stop；检查完按 Ctrl+S 保存后关闭模型。

预期：初始 Q=0；Set 脉冲后 Q=1；S 回到 0 后 Q 保持 1；Reset 脉冲后 Q=0；R 回到 0 后 Q 保持 0。不要把 S、R 同时为 1 的情况当作默认测试。MATLAB 教学函数在此时报错；官方 S-R Flip-Flop 文档将这种输入列为应避免的状态，并不等同于本函数的报错策略。

以上为按官方文档整理的待执行步骤，尚未在 R2022b/R2024b 实测。八张配图是原创界面风格示意；菜单位置、端口数量及参数显示可能与本机不同。

## B. Data Type Conversion

1. 放置 Constant、Data Type Conversion 和 Display。
2. Constant 值设为 12.6，依次连接转换模块和 Display。
3. 双击转换模块，将 Output data type 先设为 single，点击 Apply、OK 后运行；预期为约 12.6，Display 的小数位显示可能影响外观。
4. 仿真停止后双击转换模块，将目标类型改为 uint8，将 Integer rounding mode 设为 Nearest，勾选 Saturate on integer overflow，点击 Apply、OK 后运行；输入 12.6 的预期结果为 13。图05是概念示意，真实参数可能以复选框而非下拉框显示。
5. 记录输出值与类型。single 是单精度浮点；uint8 是 0～255 的 8 位无符号整数。需要查看编译后的信号类型时，使用本机版本的信号数据类型显示功能；Display 只显示当前数值，不凭显示的小数位判断类型。停止仿真并保存。

## C. ECU 子系统整理

1. 新建空白模型，放置若干 Inport、Data Type Conversion 和 Outport。
2. 打开 `data/ecu_signal_catalog.csv`，每行对应一条 Inport → Data Type Conversion → Outport 链；按 SignalName 命名输入，输出可加 `_Out` 后缀；转换模块的 Output data type 按 DataType 列填写。Direction=Input 表示信号进入 VCU 模型，链尾 Outport 仅表示在模型内继续传递。
3. 例如 ABS 对应 3 条链。保留外部 Inport/Outport，只框选中间 3 个转换模块及其内部连线，不选外部端口，这样可以练习保留 3 路输入和 3 路输出的边界。图06的滤波、增益及合路图形只用于表达选区，本练习不添加这些处理。
4. 按 Ctrl+G 创建 Subsystem。
5. 检查子系统输入端口、内部模块、输出端口是否完整。
6. 返回上层，将子系统命名为 ABS。
7. 按相同方式整理 BMS、MCU 等 ECU。
8. 七类 ECU 共 11 路输入、11 路对应输出。回到共同的上层后，选中七个 ECU 子系统，保持外部端口不选，按 Ctrl+G 再封装一层，命名为 CAN。进入 CAN 检查七组仍在，再返回上层核对原 11 路连接，按 Ctrl+S 保存。

图07是另一套抽象端口示意，不能作为图06封装后的端口清单。图08也不定义 ECU 之间的报文转发关系；本练习七类 ECU 均为输入来源，不依据图片左右位置改变 CSV 的 Direction。

CAN 只是模型组织命名，不代表已实现报文解析、CAN Pack/Unpack 或真实总线转发。

## 检查清单

- [ ] Set 只接 S，Reset 只接 R，Q 接观察模块。
- [ ] Scope 看随时间变化的波形；Display 看当前数值。
- [ ] 转换模块目标类型符合练习要求。
- [ ] 每个 ECU 子系统只封装对应 ECU 的信号处理模块。
- [ ] 创建后检查 Inport/Outport 数量和连线。

## 官方资料（文档核对，不代表本机运行）

- [S-R Flip-Flop](https://www.mathworks.com/help/simulink/ref_extras/srflipflop.html)：正式名称、端口、初始状态及同时有效条件。
- [Pulse Generator](https://www.mathworks.com/help/simulink/slref/pulsegenerator.html)：Time based 与 Sample based 的单位、步长关系。
