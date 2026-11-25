# 第13期 · 验证记录

准备日期：2026-11-25。

- [x] 内容限定在 RS 触发器、Data Type Conversion 和 ECU 子系统整理。
- [x] RS 参考逻辑区分 Set、Reset、Hold；同时有效时本教学程序报错，不声称代表所有 Simulink 模块。
- [x] ECU 信号为虚构教学数据，不含企业协议、标定或实车日志。
- [x] 明确区分模型内信号组织与真实 CAN 报文转发。
- [x] Python 独立参考检查已在准备环境执行；仅验证参考逻辑和 CSV 数据。
- [x] 发布审核重新执行 `python3 tools/check_reference.py`：0～10 s、步长 0.1 s，共 101 个参考采样点；CSV 为 11 个唯一信号、7 个 ECU 分组，全部 Direction=Input。
- [x] MATLAB 脚本、CSV 和教学预期已人工静态核对：RS 时序统一到 10 s；新增 uint8 数值与各 ECU 信号数量断言，共 13 项，尚未执行。
- [x] 手动步骤改用官方模块名 S-R Flip-Flop，区分 Time based 秒值与 Sample based 样本数，并明确初始状态、boolean 输入与 Scope/Display 用途。仅核对官方文档，非本机实测。
- [x] 八张独立 PNG 已逐张检查并按图01～图08原名加入 figures；README 使用相对路径，标明原创教学示意，非实际软件运行截图。
- [x] 图06～08的抽象结构与 CSV 数据边界已在图注、练习中说明；不将图中的增益、ABS控制输出或“经CAN”字样作为已实现功能。
- [ ] MATLAB R2022b/R2024b 执行脚本。
- [ ] MATLAB 断言测试。
- [ ] Simulink 中 RSFlipFlop、Pulse Generator、Data Type Conversion 和 Subsystem 手动搭建。
- [ ] 核对本机 RSFlipFlop 的端口和 S/R 同时有效行为。
- [ ] MIL/SIL/HIL、台架和实车验证。

**当前状态：Python 参考逻辑检查通过；MATLAB/Simulink 实机验证待完成。**

发布审核输出：

```text
PASS: Python RS reference: 101 samples (0..10 s, step 0.1 s)
PASS: CSV catalog: 11 unique signals, 7 ECU groups, all Input
MATLAB/Simulink were not executed.
```

本输出来自 Python 独立参考检查，不运行或证明 MATLAB 的 13 项断言通过；`run_tests.m` 中 PASS 文字只有本机实际执行到末尾时才会产生。未提交未经验证的 SLX 文件。
