# Simulink · 建模与结构检查练习

这里按Simulink主题整理独立教学实验，从建块、命名和连线，逐步练习配置与检查。

## 已发布练习

| 主题 | 配套内容 | 验证状态 |
| --- | --- | --- |
| [第04期：一个模块50路Outport，批量创建、命名和连接](batch-outports/) | 5路入门、50路模拟子系统、统一配置、显式端口映射、结构检查与8关排错练习 | 已人工阅读代码与说明；MATLAB/Simulink实机验证尚未完成 |
| [第05期：CAN Pack、CAN Unpack、From 和 Goto](05-can-pack-unpack-routing/) | 虚构DBC、三组报文、信号流向图、搭建练习与标签名称初筛 | MATLAB与CAN Pack/Unpack尚未实测；[CSDN第05期](https://blog.csdn.net/qian123456wang/article/details/169555029) |

## 怎样使用

1. 先读本期README，下载本期全部.m文件到独立练习文件夹。
2. 先完成5路入门，再运行50路示例。
3. 按practice.md修改配置、主动制造错接，观察检查器的反应。
4. 将真实运行版本、报错与结果填入VALIDATION.md。

CSDN第04期对应Outport批量建模主题，文章讲操作思路，本目录提供代码和实验。[阅读CSDN第04期文章](https://blog.csdn.net/qian123456wang/article/details/169361654?spm=1001.2014.3001.5502)。信号与模型均为虚构教学设计。

[返回仓库首页](../../README.md)

