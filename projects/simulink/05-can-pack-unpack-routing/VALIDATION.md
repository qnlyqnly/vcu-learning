# 第05期 · 验证记录

整理日期：2026-10-30。所有报文、节点、标签和数据均为虚构教学设计。

## 已完成的检查

- 已补充作者提供的[CSDN第05期正式文章链接](https://blog.csdn.net/qian123456wang/article/details/169555029)。

- 人工核对DBC：标准ID 0x321=801，长度8字节，VehicleSpeed占bit0..15，Ready占bit16，定义不重叠、不越界。
- 手算三组原始值及物理值，并用独立Python位运算与两个CSV交叉核对：Case1=(0,0.0,0)，Case2=(123,12.3,1)，Case3=(456,45.6,1)。
- 阅读MATLAB名称初筛函数，核对三类候选问题：From缺同名Goto、Goto缺同名From、重复Goto名称。
- 核对README中的Mermaid源文本与docs/signal_flow.mmd一致，检查本期相对文件链接。

Python核对只涉及DBC文本约定、字节、缩放与CSV，不调用MATLAB，也不是DBC解析器导入或CAN Pack/Unpack验证。

## 尚未完成

| 项目 | 当前状态 |
| --- | --- |
| DBC导入真实解析器、CANdb++或Vehicle Network Toolbox | 未验证 |
| From/Goto空白模型搭建、Ctrl+D更新及仿真 | 未运行 |
| Check_FromGoto_OrphanTags.m在MATLAB中执行 | 未运行 |
| MATLAB R2022b / R2024b兼容性 | 未验证 |
| CAN Pack/Unpack离线闭环与输出数值 | 未实测 |
| Mermaid在GitHub页面的渲染 | 待网页检查后记录 |
| CAN设备、CAN通道、实车及代码生成 | 未执行，不作为本期完成条件 |

仓库没有预制.slx，也没有DBC自动加载脚本；练习要求由读者在独立模型中实际操作。

## 名称初筛工具的边界

函数只读一个已加载模型，按GotoTag做精确且区分大小写的名称比较，不更新、不保存、不修改模型。

- 不解析local/scoped/global可见性，不检查Goto Tag Visibility关系或跨非虚拟子系统边界。
- 不进入掩码内部、库链接内部、引用模型内部；变体覆盖取决于find_system与模型状态，未做变体分析。
- 不同合法local作用域里的同名Goto也会列为重复候选，不能直接判为错误。
- 名称匹配仍可能不可见；搜索覆盖外的对应块可能造成“缺匹配”误报。
- 没有候选问题或报告为空，均不能证明模型、路由或功能正确。

## 待实际执行的检查表

| 场景 | 预期 | 实测结果 |
| --- | --- | --- |
| 同层Constant12.3→Goto，From→Display | Display为12.3 | 待填写 |
| Constant改45.6 | Display为45.6 | 待填写 |
| From标签多写_X | FROM_WITHOUT_NAME_MATCH | 待填写 |
| 移除唯一From | GOTO_WITHOUT_NAME_MATCH | 待填写 |
| 两个同名Goto | DUPLICATE_GOTO_NAME候选，人工核查 | 待填写 |
| 同名From移到外层local Goto不可见的子系统 | 初筛可能无提示，更新模型发现实际问题 | 待填写 |
| 不同子系统各有合法同名local Goto | 初筛提示重复候选，但实际未必冲突 | 待填写 |
| 搜索覆盖内没有From/Goto | 返回空表，不声称全工程无标签 | 待填写 |
| 3组Pack→Unpack | 读回对应物理值与Ready | 待填写 |

## 实际运行填写

| 信息 | 记录 |
| --- | --- |
| 操作日期 | 待填写 |
| MATLAB / Simulink / Vehicle Network Toolbox版本 | 待填写 |
| Git提交及模型名称 | 待填写 |
| 操作场景 | 待填写 |
| 真实输出或完整报错 | 待填写 |
| 是否做硬件收发 | 没做就填写“未做” |
