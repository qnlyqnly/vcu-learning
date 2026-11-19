# 第11期 · 一次改一个条件

先在本期目录执行 README 中的 MATLAB 初始化命令，再执行 `p=demo_parameters();`。下面均为离线教学实验，不连接车辆。默认回归测试针对原始参数，改参后先直接运行单个仿真。

## 练习1：只增加母线电容

前提：默认正常流程。输入/操作：`p.capacitanceF=0.010; out=simulate_precharge(p,'normal');`。

观察：`out.summary.theoreticalThresholdTimeS`、`out.Log.VoltageRatio`、`HvReady` 和 `FaultCode`。

预期：时间常数变为1 s，理论95%时间约2.995732 s，向上取采样拍为3.00 s；恰好到预充超时截止拍仍可接受达标电压。正常路径参考完成时刻约3.28 s。这是待在 MATLAB 验证的边界练习，不是本次运行结果。

## 练习2：再把电容增到0.012 F

前提：重新执行 `p=demo_parameters();`。输入/操作：仅设 `p.capacitanceF=0.012`，运行正常场景。

观察：3 s预充时间结束时的电压比例、`MainPosCmd` 和 `FaultCode`。

预期：理论95%时间约3.594879 s，超过3 s；进入预充超时，主正命令始终0。先判断现象，再决定需要调整哪项教学假设；不要把延长超时当作真实车辆故障的解决方法。

## 练习3：让主正反馈变慢

前提：恢复默认参数。输入/操作：先设 `p.closeDelayS(3)=0.20`，再试0.30和0.31 s。

观察：`MainPosCmd` 已为1而 `MainPosFb` 仍为0的区间内，`PrechargeCmd` 是否保持为1；`HvReady`何时置位。

预期：0.20 s可正常完成；0.30 s恰好在反馈确认截止拍到达，应该接受；0.31 s应先进入主正确认超时。FAULT后全部命令撤销，后续迟来的动作不能使状态自动恢复。

## 练习4：主正闭合了，为何还不完成

前提：默认参数。输入/操作：`out=simulate_precharge(p,'pre_open_stuck');`。

观察：2.65 s以后 `MainPosFb=1`、`PrechargeCmd=0`，但 `PrechargeFb`仍为1。

预期：不能完成；预充退出确认超时后FAULT。解释为什么“发出断开命令”和“确认断开”不同，以及为什么FAULT中的电压/反馈还需要看。

## 练习5：区分高压完成与驱动准备

前提：默认参数。输入/操作：运行 `'mcu_not_ready'`，再恢复 `'normal'`。

观察：`HvReady`、`McuHvOk`、`McuDriveReady`、`DriveReady`。

预期：前者高压回路可以完成，但DriveReady始终为0；后者默认MCU状态有效。不要把此简化的DriveReady当作包含所有整车驱动条件的最终结论。

## 练习6：在 Stateflow 实际搭建（尚未完成）

这是将参考逻辑搬到图形模型的后续练习，本仓库没有已验证的SLX。

1. 建一个离散模型，固定步长0.01 s，停止时间5 s；用Chart表示控制器，用独立子系统表示接触器反馈和RC回路。
2. Chart顶层保留OFF、CLOSE_NEG、PRECHARGE、CLOSE_POS、HV_READY、FAULT；为CLOSE_POS保留“主正确认前／预充退出确认”内部阶段。
3. 为三个命令和三个反馈分别声明信号。接触器子系统对闭合/断开分别延时，不能直接把Cmd接回Fb。
4. RC子系统用 `U_next=Ubatt-(Ubatt-U)*exp(-dt/(R*C))`，只有实际主负和预充闭合才充电；主正闭合后的理想处理和故障断开后的残余电压应与README的边界一致。
5. 用Scope观察电池/母线电压、命令与反馈波形；用Display看当前值。先跑正常流程，再复现README五个必要故障。
6. 导出实际波形，与参考CSV按时间对齐。记录状态机执行次序是否多一拍；实测后再更新VALIDATION，不能用图01～03代替真实结果。

## 自己填写完成记录

| 项目 | 当前状态 | MATLAB/Simulink版本、观察和证据 |
| --- | --- | --- |
| 默认仿真与14组MATLAB回归 | 未验证 | |
| 0.010 F／0.012 F边界 | 未验证 | |
| 主正0.20／0.30／0.31 s延时 | 未验证 | |
| 预充退出拒动 | 未验证 | |
| MCU驱动准备条件 | 未验证 | |
| Stateflow实际搭建与对齐 | 未完成 | |

[返回第11期](../README.md) · [查看验证记录](../VALIDATION.md)
