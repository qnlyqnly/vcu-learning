# 第13期 Simulink 动手练习

## A. RSFlipFlop

1. 打开 MATLAB，在命令窗口输入 `simulink` 并回车。
2. 选择 Blank Model，按 Ctrl+Shift+S 保存为 `Issue13_RS_Practice.slx`。
3. 设置 Stop Time 为 8。
4. 在 Library Browser 搜索 `RSFlipFlop`，按当前版本实际显示的端口标签确认 R、S、Q。
5. 放置两个 Pulse Generator、一个 Scope 和一个 Display。
6. Set 脉冲目标为 1～2 s；Reset 脉冲目标为 6～7 s。可用 Time-based、Amplitude=1、Period=10 s、Pulse width=10%、Phase delay 分别为 1 s 和 6 s；字段以当前模块对话框为准。
7. Set 接 S，Reset 接 R，Q 分支接 Scope 和 Display。
8. 保存并运行。Scope 看完整波形，Display 看当前仿真值。

预期：初始 Q=0；Set 后 Q=1；Set 释放后 Q 保持 1；Reset 后 Q=0；Reset 释放后 Q 保持 0。不要把 S、R 同时置 1，除非已经查明当前模块对该组合的定义。

## B. Data Type Conversion

1. 放置 Constant、Data Type Conversion、Display。
2. Constant 设置为 12.6，依次连接三个模块。
3. 双击 Data Type Conversion，检查 Output data type。
4. 分别尝试 single 与 uint8，检查舍入方式和整数溢出处理。
5. 运行并记录输出值与类型。MATLAB uint8 转换与 Simulink 模块的所有参数设置不应混为一谈。

## C. ECU 子系统整理

1. 为同一 ECU 的练习信号放置输入端口和处理模块。
2. 只框选同一 ECU 的相关模块及连线。
3. 按 Ctrl+G 创建 Subsystem。
4. 双击子系统检查输入、内部模块、输出连接。
5. 返回上层，将子系统命名为 ABS 或 BMS 等。
6. 按同样方式整理其他 ECU，最后可将这些子系统放入名为 CAN 的上层子系统。

这里 CAN 是模型层级命名，不代表实现了 DBC 解码、CAN Pack/Unpack、真实总线发送或网关转发。
