# 第13期 · 验证记录

准备日期：2026-11-25。

- [x] 内容限定在 RS 触发器、Data Type Conversion 和 ECU 子系统整理。
- [x] RS 参考逻辑区分 Set、Reset、Hold；同时有效时本教学程序报错，不声称代表所有 Simulink 模块。
- [x] ECU 信号为虚构教学数据，不含企业协议、标定或实车日志。
- [x] 明确区分模型内信号组织与真实 CAN 报文转发。
- [x] Python 独立参考检查已在准备环境执行；仅验证参考逻辑和 CSV 数据。
- [ ] MATLAB R2022b/R2024b 执行脚本。
- [ ] MATLAB 断言测试。
- [ ] Simulink 中 RSFlipFlop、Pulse Generator、Data Type Conversion 和 Subsystem 手动搭建。
- [ ] 核对本机 RSFlipFlop 的端口和 S/R 同时有效行为。
- [ ] MIL/SIL/HIL、台架和实车验证。

**当前状态：Python 参考逻辑检查通过；MATLAB/Simulink 实机验证待完成。**
