# 第12期 · 验证记录

准备日期：2026-11-20。

## 1. 文件与静态检查

- [x] 项目独立位于 `projects/simulink/12-debounce-and-filtering/`。
- [x] 两个实验相互独立：开关消抖与连续数值低通滤波。
- [x] 消抖 MATLAB 示例使用连续稳定样本计数；不冒充 MathWorks Stateflow 官方模型。
- [x] 滤波 MATLAB 示例使用一阶离散 IIR 指数系数；明确区别于官方 Basic Filter 模型中的 FIR。
- [x] 参数、信号名、图注和README描述已对齐。
- [x] 官方 MathWorks 文档链接及关键参数已核对。
- [x] 配图为工程软件风格原创教学界面，不冒充真实 MATLAB 运行截图或官方原图。
- [x] 公开资料不包含企业内部模型、协议、标定或实车日志。

## 2. Python 独立参考检查

已运行 `python tools/check_reference.py`（标准库，不依赖第三方包）：

- 消抖样本周期 1 ms，稳定确认样本数 10。
- ON 输出边沿预期 0.169 s。
- OFF 输出边沿预期 0.469 s。
- 输出总共两次状态切换；两段触点抖动没有触发额外输出变化。
- 一阶滤波系数 `a=exp(-Ts/tau)`，`Ts=1 ms`、`tau=25 ms`。
- 稳态区间内，滤波残差标准差小于原始残差标准差。

检查输出见 `examples/python_reference_check.txt`，独立参考轨迹见：
- `examples/debounce_reference.csv`
- `examples/filter_reference.csv`

**这些结果只验证 Python 独立参考计算，不是 MATLAB 代码运行结果。**

## 3. MATLAB 与 Simulink 验证

- MATLAB 脚本已编写，尚未在 MATLAB R2022b/R2024b 中执行。
- `tests/run_tests.m` 的10项断言已编写，尚未执行。
- 未提供未经生成和运行验证的 `.slx` 文件。
- MathWorks 官方 Stateflow 消抖示例与 Simulink Basic Filter 模型只核对了文档说明和参数，尚未在本机打开、运行。
- 没有进行 MIL、SIL、HIL、台架或实车验证。

## 4. 待完成

- [ ] 在 MATLAB 中执行 `run_all_demos(false)`。
- [ ] 在 MATLAB 中执行 `run_tests()` 并记录通过数。
- [ ] 在 MATLAB 中执行 `run_all_demos(true)`，检查输出波形。
- [ ] 按官方网页打开 `sf_debouncer` 并运行 Stateflow 示例。
- [ ] 使用 Basic Filter 模板创建并运行官方 FIR 示例。
- [ ] 若用户提供实际 MATLAB 截图，再替换教学示意图；不能把示意图称为实测截图。

当前状态：**Python 参考检查通过；MATLAB/Simulink/Stateflow 实机验证待完成。**
