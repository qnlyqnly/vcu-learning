# 第07期 · 搭建与辨错练习

全部名称和数值为独立设计的教学示例；本页是练习任务与预期，不是已经完成的操作报告。

## 练习1：按表搭出一个连接

1. 打开 [接口表](../examples/interface_contract.csv)，说出接口、数据元素、数据类型三者各叫什么。
2. 对照 [组件表](../examples/components_ports.csv)，分别找到两个SWC类型、两个实例及P/R端口。
3. 在独立Developer工作区按 [本期README](../README.md) 建立对象。
4. 在DemoSpeedComposition中加入两个组件原型，核对它们引用的类型。
5. 依 [连接表](../examples/connections.csv) 建立Conn_VehicleSpeed，选择正确的两端。
6. 保存、重开并检查结构，记录实际结果，不修改公司工程。

本期不编写Runnable，不设置AccessPoints，不生成RTE，也不通过车速显示值证明连线有效。

| 核对项 | 纸面预期 | 实际结果 |
| --- | --- | --- |
| Source实例引用类型 | SpeedSource_SWC | 未验证 |
| Monitor实例引用类型 | SpeedMonitor_SWC | 未验证 |
| 提供端 | SpeedSource.Pp_VehicleSpeed | 未验证 |
| 使用端 | SpeedMonitor.Rp_VehicleSpeed | 未验证 |
| 双方接口 | 同一个If_VehicleSpeed | 未验证 |
| 数据元素与应用类型 | VehicleSpeed / Dt_VehicleSpeed | 未验证 |
| 保存重开后的连接 | 两端仍正确 | 未验证 |
| 工具检查消息 | 逐项记录结构问题与后续未配置项 | 未验证 |

## 练习2：一次只改一处

先保存原练习，再在副本上修改。不要为让检查窗口变干净而随意删对象。

| 改动 | 自己先判断 | 参考检查思路 |
| --- | --- | --- |
| 把Monitor的Port改成P-Port | 两个P能否建立本例所需连接？ | 本例需要提供端P和使用端R，不能用两个P代替 |
| 两侧接口都叫If_VehicleSpeed，但实际来自两个不同包 | 只看名字够不够？ | 检查完整引用路径、接口种类、数据元素和类型；本例恢复为同一个接口对象 |
| Port名字正确，但连接到了另一个组件实例 | 名称对是否代表连接对？ | 对照连接表，检查所属实例和类型，不仅检查Port名 |

不同版本的工具可能在创建、连接或检查阶段提示问题，不预先编造报错文字。同名不同路径也不一概等同于绝对不兼容；本例通过复用同一个接口对象消除歧义。

## 练习3：三道自测

1. Pp_VehicleSpeed和Rp_VehicleSpeed名称不同，能否在本例中连接？
2. 已创建SpeedSource_SWC类型，却未放入Composition，是否已经有SpeedSource实例？
3. 画布出现一条连接线，能否宣布车速已经在软件中传输？

### 参考答案

1. 可以。名称无需相同，关键是本例P/R方向、接口引用及相关数据约定正确。
2. 不能这么认为。类型定义与Composition中的组件原型是两件事；本例需显式加入并命名实例。
3. 不能。当前只建立结构连接，没有执行行为、RTE配置、生成或运行验证。

## 没有软件时怎么练？

直接在GitHub读三个CSV和SVG，自己遮住答案，口述“Composition → 实例 → 类型 → Port → Interface → 数据元素”。能对照定位对象即可，不需要先购买设备，也无需Python。

实际完成后在 [验证记录](../VALIDATION.md) 中填写版本、动作、消息和结果。只记录确实执行过的项目。

[返回本期](../README.md)
