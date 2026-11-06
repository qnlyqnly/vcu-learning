# 工具职责、安装准备与许可证检查

## 两个工具分别做什么？

| 工具 | 本期先理解的职责 | 本期练习边界 |
| --- | --- | --- |
| DaVinci Developer Classic | 定义应用SWC、接口、Port及Composition中的连接 | 车速两组件的结构搭建 |
| DaVinci Configurator Classic | 配置、检查并生成MICROSAR Classic基础软件和RTE，承担集成工作 | 只认识其职责，不配置或生成RTE |

它们有协同和重叠的视图，不是“画完Developer就自动完成全部配置”。Developer中的连接定义谁与谁交换什么；实际执行和集成仍有后续步骤，本期不展开。

## 安装前先填这张表

| 项目 | 需要确认什么 | 本次状态 |
| --- | --- | --- |
| 安装来源 | Vector官方交付或组织授权渠道 | 待确认 |
| Developer / Configurator版本 | 完整版本与补丁号，符合配套要求 | 待读者填写 |
| AUTOSAR版本 | 按练习环境支持版本选择，不随意混用 | 待确认 |
| 配套组件 | 按该版本安装说明安装所需External Components | 待确认 |
| 许可证方式 | 软件许可、网络许可或Keyman等实际载体 | 待确认 |
| 授权产品范围 | 是否包含要使用的工具和功能 | 待确认 |

官方当前产品说明可能对应不同于学习资料的版本；不要按最新页面猜测旧版按钮位置。

## 准备顺序

1. 从合适的授权渠道取得安装包及对应版本说明，核对系统要求和工具配套关系。
2. 按安装向导安装Developer、需要的配套组件；Configurator仅在具备对应包和许可时安装。本期只认识其作用，不为练习连Port强行搭建完整集成工程。
3. 按所用许可方案检查Vector License Client。若有Keyman，按对应版本的官方说明准备驱动并检查识别情况；插入顺序和是否重启以安装说明为准，不套用其他产品步骤。
4. 确认工具能启动、许可证包含目标功能，再新建独立练习工作区。
5. 记录版本与检查结果，回到 [本期步骤](../README.md) 创建对象。

Keyman是许可证载体之一，不是CAN收发设备。拥有USB加密狗或安装成功，不等于自动拥有Developer、Configurator及全部功能的许可；也不是每种许可都需要加密狗。

本仓库不提供安装包、驱动副本、激活密钥、许可证文件或绕过授权的方法。没有适用授权时，可先阅读对象表和图，不宣称已完成软件操作。

## 启动遇到问题时

| 现象 | 先检查 |
| --- | --- |
| 软件装好了但提示许可证问题 | 产品/功能、许可载体及授权状态 |
| Keyman未识别 | 官方驱动要求、连接和许可客户端中的识别状态 |
| 两工具工程无法配套 | 工具及补丁、AUTOSAR版本、官方支持的工作区关联方式 |
| Port无法连接 | 所属实例、P/R方向、接口引用和数据类型，不能先归因于许可 |

这里只是检查顺序，不是针对某个真实故障的诊断结论。

参考：[Developer](https://www.vector.com/en/product/microsar-classic/davinci-developer-classic/) · [Configurator](https://www.vector.com/en/product/microsar-classic/davinci-configurator-classic/) · [Vector License Client帮助](https://support.vector.com/kb?id=kb_article_view&sys_kb_id=26427c472bfcf65034d2f47ebe91bff3)

[返回本期](../README.md)
