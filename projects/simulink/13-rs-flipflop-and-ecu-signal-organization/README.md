# 第13期 · Simulink 模型开发：RS触发器与多 ECU 信号整理

配套 CSDN 正式文章：[Simulink 模型开发实战：RS触发器与多 ECU CAN 信号转发](https://blog.csdn.net/qian123456wang/article/details/171372527)。

CSDN 负责概念和操作讲解；GitHub 提供独立 MATLAB 教学参考、虚构 ECU 信号清单、练习步骤和验证记录。两边互补，不复制正文。

> 所有信号名称、数值和时序均为原创教学模拟内容，不来自企业协议、客户项目、实车采集或量产标定。“CAN 子系统”仅表示模型侧信号分类与组织，不代表 CAN 报文解码、网关路由或真实总线转发。

## 本期练习

### 1. RS 触发器：置位、保持、复位

采用高电平有效的独立教学参考逻辑：S=1、R=0 时置位；S=0、R=1 时复位；S=0、R=0 时保持上一状态。S/R 同时有效时，本练习明确报错，不自行假设 Simulink 模块优先级。真实模块行为应以本机版本帮助和实测为准。

默认时序：S 在 1～2 s 置位，R 在 6～7 s 复位。

### 2. Data Type Conversion

练习 double、single、uint8 类型差异，关注取整方式、目标类型范围和溢出处理。MATLAB 类型转换示例不等于覆盖所有 Simulink 模块参数组合。

### 3. 多 ECU 信号分类与子系统组织

使用虚构信号清单，按 ABS、BMS、MCU、BCM、DCDC、OBC、TBOX 分类。练习将同一 ECU 的相关模块封装为 Subsystem，再放入上层 CAN 子系统。

本练习不包含 DBC 解析、CAN ID/字节序/起始位解析、CAN Pack/Unpack、硬件收发或网关白名单配置。

## 文件结构

- matlab/：RS 状态参考、类型转换、ECU 分组和运行入口。
- data/：原创虚构 ECU 信号清单。
- tests/：MATLAB 断言，待用户本机执行。
- tools/：独立 Python 参考检查。
- exercises/：Simulink 手动搭建步骤。
- VALIDATION.md：验证边界和未完成事项。

## MATLAB 运行

在 MATLAB 当前文件夹切换到本期项目根目录，在命令窗口执行：

    addpath('matlab','tests');
    results = run_all_demos();
    report = run_tests();

结果 CSV 写入 outputs/。脚本使用基础 MATLAB，不要求 Simulink；Simulink 手动搭建步骤见 exercises/README.md。

## 与 CSDN 的分工

- CSDN：RS 触发器端口、置位保持复位、数据类型转换、ECU 分类和 Ctrl+G 子系统操作。
- GitHub：可运行的基础 MATLAB 参考逻辑、虚构信号清单、测试和操作练习。

[返回 Simulink 项目目录](../README.md) · [返回仓库首页](../../../README.md)
