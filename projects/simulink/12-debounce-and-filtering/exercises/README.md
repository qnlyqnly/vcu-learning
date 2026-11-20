# 第12期动手练习：消抖与滤波

本目录配套 `../README.md`。所有输入都是原创教学信号，不代表真实车辆采集数据。

## 练习A：消抖

1. 在 MATLAB 当前文件夹切换到项目根目录。
2. 执行 `addpath('matlab','examples','tests')`。
3. 执行 `p=demo_parameters(); d=run_debounce_demo(p);`。
4. 查看 `d.Data(:,1:4)`，比较 IntendedState、RawInput 和 DebouncedOutput。
5. 把 `p.DebounceTime` 从 0.010 改为 0.005，再运行，观察输出边沿是否提前。
6. 把 `p.DebounceTime` 改为 0.020，再运行，观察真实开关操作确认延迟如何变化。
7. 把 `p.BounceDuration` 改为 0.025，检查 10 ms 消抖是否仍能滤除整个抖动过程。

思考：如果真实有效开关变化持续时间短于设定消抖时间，会发生什么？为什么不能盲目把消抖时间设得很长？

## 练习B：一阶低通滤波

1. 执行 `p=demo_parameters(); f=run_filter_demo(p);`。
2. 查看 `f.Alpha`、`f.Summary` 和 `f.Data`。
3. 将 `p.FilterTau` 改为 0.010、0.025、0.050 s，分别运行。
4. 比较 `FilteredResidualStd`，同时观察输出相对输入的响应滞后。
5. 将 `p.InterferenceFrequency` 改为 8 Hz，再与 30 Hz 的结果比较。

思考：为什么同一个滤波器对不同频率的干扰抑制程度不同？时间常数变大后，为什么真实信号的变化也更慢？

## 练习C：方法选择

对每个信号写下“信号类型、主要异常、建议处理方式、响应风险”：

- 机械开关的短时触点跳变；
- 电机转速测量值叠加高频噪声；
- 温度信号经过阈值后在边界附近反复切换；
- CAN 报文超过规定周期没有更新。

注意：最后一种首先应考虑通信超时与故障诊断，不能用低通滤波代替报文超时监测。温度阈值附近的状态抖动可能需要滞回或持续时间确认，具体取决于需求。

## 练习D：官方模型

- Stateflow 消抖：打开 MathWorks 官方 `Reduce Transient Signals by Using Debouncing Logic` 页面，使用 Open Model 打开 `sf_debouncer`，观察 `Debouncer` Chart 和 Scope。
- Simulink 低通 FIR：在 MATLAB Home > Simulink > Basic Filter 创建官方模板，观察两路 Sine Wave、Gaussian Noise、Sum、Lowpass FIR Filter 和 Spectrum Analyzer。

官方模型属于学习参考；本项目没有复制官方 `.slx`，也没有声称已在本机运行。需要将实际版本、工具箱、运行结果和截图记录到 `VALIDATION.md` 后，才能把状态更新为已验证。
