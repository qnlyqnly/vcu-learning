# 第11期 · 验证记录

审核日期：2026-11-19。新增内容均为自行设计的教学参数、代码、故障注入与配图；未读取或使用内部整车模型、真实标定、企业协议、客户信息或付费材料。

## 1. 已完成的文件与静态审核

- [x] 读取发布前main的根README、AGENTS、projects总索引、simulink索引、vehicle-dynamics索引；检查第10期完整文件结构、全部文本文件和VALIDATION。
- [x] 新增`projects/vehicle-control/11-vcu-hv-precharge/`，期数接续10；保留原项目标题、路径、文章链接和验证状态。
- [x] 函数名与文件名一致；入口、参数、仿真、绘图、测试之间的调用路径已静态检查。
- [x] 六状态、命令与反馈分离、主正确认前保持预充、预充退出确认、请求/许可/中止优先级及FAULT锁存已人工审阅。
- [x] 主负、预充、主正闭合确认分别计时；预充电压和预充退出另有独立超时。
- [x] 数值单位、RC离散更新、采样拍取整及两个时间原点已核对。
- [x] 三张本地PNG可解码，另生成同内容SVG用于仓库网页发布；图号/名称与README对应，内容和数值已目视检查。
- [x] README及索引的相对链接、图片路径已离线检查；原01～10期条目保留。
- [x] 没有伪造`.slx`，没有将界面示意或Python参考结果当作MATLAB实测。

## 2. 本次实际执行的检查

| 检查 | 命令/方法 | 实际结果与范围 |
| --- | --- | --- |
| MATLAB可用性 | 查找`matlab`、`octave`可执行程序 | 均未发现；没有执行MATLAB或Octave |
| 第三方MATLAB静态检查 | `mh_lint --brief projects/vehicle-control/11-vcu-hv-precharge` | 5个.m文件，0项问题；这是MISS_HIT，不是MathWorks Code Analyzer |
| 独立数学参考 | `python tools/check_reference.py --write` | 12个场景＋RC公式＋主正反馈截止时刻，共14组参考检查通过 |
| RC数值 | Python解析公式 | I0=6 A，tau=0.8 s，t95=2.396585818843 s；阈值570 V |
| 正常时序参考 | 解析事件时刻＋501点参考CSV | 首次达标2.60 s，主正反馈2.65 s，预充退出并完成2.68 s |
| 文件/图像检查 | 函数入口、链接路径、PNG解码与目视检查 | 文件完整；本地PNG均为1920×1200，发布SVG使用等比例矢量画布；原项目文件不纳入修改 |

实际Python日志是[python_reference_check.txt](examples/python_reference_check.txt)，汇总是[python_reference_summary.csv](examples/python_reference_summary.csv)，正常参考轨迹是[python_reference_normal.csv](examples/python_reference_normal.csv)。`check_reference.py`先按公式计算事件时刻，再构造参考波形，**没有解释或执行任何.m文件**。它只能验证数学和规格参考的一致性，不能证明MATLAB实现执行正确。

## 3. 必要的五组测试，证据分别记录

每组的完整“前提—操作—观察—预期”见[README测试表](README.md)。这里仅记录实际执行范围。

| 测试 | Python独立参考 | MATLAB同名场景与断言 |
| --- | --- | --- |
| 01 正常预充成功 | 通过：2.68 s完成；主正确认后才撤预充 | 未执行 |
| 02 电压始终不足 | 通过：3.20 s超时；主正命令/完成始终0 | 未执行 |
| 03 主负拒动 | 通过：0.40 s超时；不发预充命令 | 未执行 |
| 04 预充中撤上电许可 | 通过：1.00 s中止；不发主正命令 | 未执行 |
| 05 主正拒动 | 通过：2.90 s超时；等待主正期间保持预充；不完成 | 未执行 |

额外7个Python场景也通过规格检查：预充拒动、预充退出拒动、预充中主负反馈丢失、完成后反馈丢失、撤请求、中止请求、MCU未驱动准备。主正反馈恰好到截止拍的参考检查也通过。

MATLAB的`run_tests.m`共有14组：12个场景＋反馈截止时刻＋5种无效电容输入的参数组。**这14组MATLAB断言均未执行。** 它与“14组Python参考检查”不是同一批执行证据。

## 4. 配图来源与证据限制

| 图号 | 文件 | 来源与作用 |
| --- | --- | --- |
| 图01 | 图01_Simulink高压上电状态机.svg | 确定性绘制的Simulink/Stateflow风格教学界面，解释六状态及反馈接口 |
| 图02 | 图02_Scope预充电压变化.svg | 从Python正常参考CSV绘制的Scope风格界面：600 V、570 V、RC上升及命令 |
| 图03 | 图03_继电器控制时序.svg | 同一CSV的三组命令/反馈及HvReady，显示0.05 s闭合、0.03 s断开延时 |

网页发布使用SVG格式，脚本同时生成同名PNG；当前不把PNG写入仓库。三张均由`tools/render_figures.py`生成，包含醒目的“EDUCATIONAL UI MOCKUP / NOT a MATLAB run screenshot”说明，不是AI生成的数值曲线，也不冒充真实软件截图。没有使用真人、实验室照片或装饰海报。它们不能证明Simulink、Stateflow或MATLAB运行通过。

## 5. 链接与发布范围

CSDN采用作者指定的正式地址：`https://blog.csdn.net/qian123456wang/article/details/171017310`。本次网络读取该页面失败，搜索无收录结果，因此**仅核对URL与授权一致，未成功核对线上标题、正文或图号**；本项目图01～03是本GitHub练习的编号。README按本次给定范围编写，没有声称复制或逐段审核CSDN正文。

本次通过GitHub普通网页向main新增vehicle-control分类及第11期共18个文件，更新根README与projects/README两份总索引。第01～10期项目、AGENTS、simulink索引和vehicle-dynamics索引均保留，不修改其内容。

三张配图以SVG格式分别保存并嵌入README；脚本可同时生成同名PNG，但本次不把PNG文件写入仓库。发布文件与审核稿按Git blob SHA复读核对，仓库三图显示另作网页检查。验证范围仍限定为本页列出的静态检查与Python参考检查，不能称为MATLAB运行通过。

## 6. 尚未完成，不能宣称通过

- [ ] 真实MATLAB R2022b/R2024b执行`run_all_examples(false)`并保存版本和命令窗口输出。
- [ ] 真实MATLAB执行`run_tests()`的14组断言，记录实际通过/失败数。
- [ ] 真实MATLAB绘图，并将输出与参考CSV逐采样点对齐。
- [ ] 实际生成和运行Simulink/Stateflow模型，复现必要五组测试。
- [ ] 主负/主正断开拒动、辅助触点与功率触点不一致、传感器失真、粘连诊断、负载/泄放及正常下电扩展。
- [ ] MIL、SIL、HIL、硬件、台架、实车或功能安全验证。

当前结论：可供离线阅读与本地MATLAB待验证运行的教学参考；实际通过的是第三方静态检查和独立数学/时序参考检查，**不能称为MATLAB仿真通过或实车策略验证完成**。
