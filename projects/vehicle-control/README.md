# VCU 控制策略 · Vehicle Control

这里用原创离线模型练习 VCU 的状态管理、控制命令、实际反馈和故障处理。教学架构、数值与故障注入均为自行设计，不代表真实车型。

| 期数 | 项目 | 配套文章 | 验证状态 |
| --- | --- | --- | --- |
| 11 | [VCU 高压上电与预充控制——MATLAB 离线仿真及故障测试](11-vcu-hv-precharge/) | [CSDN 第11期](https://blog.csdn.net/qian123456wang/article/details/171017310) | Python 独立参考检查14组通过；5个.m静态检查完成；MATLAB／Simulink 未实测 |

建议先完成[第10期功率与扭矩计算](../vehicle-dynamics/10-vcu-powertrain-formulas/)，再进入本期状态机与反馈练习。高压上电完成与 MCU 驱动准备是不同状态。

- [返回项目总目录](../README.md)
- [返回仓库首页](../../README.md)
