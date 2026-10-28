# 第04期 · Simulink 批量创建、命名和连接 Outport

**问题：** 如果一个模型需要很多有名称的输出端口（Outport），每个都手动拖入、改名、连线，很容易漏掉或接错。

本项目从**5 路虚构信号**开始：运行脚本自动创建模块，再用另一个脚本检查名称及连线。掌握方法后，可以修改名称列表继续练习。**这里只演示模块操作，不涉及实际车辆接口。**

## 先看要生成什么

```text
Source_Speed        ──────> Speed        (Outport)
Source_Torque       ──────> Torque       (Outport)
Source_Voltage      ──────> Voltage      (Outport)
Source_Current      ──────> Current      (Outport)
Source_Temperature  ──────> Temperature  (Outport)
```

左侧使用 Constant 模块模拟已有信号，右侧是自动生成的 Outport。**它不是从某个真实通信模块接收到的信号。**

## 文件及用途

| 文件 | 做什么 |
| --- | --- |
| [`create_outports.m`](create_outports.m) | 自动新建 `outport_demo.slx`，生成 5 组模块并连线 |
| [`check_outports.m`](check_outports.m) | 检查 5 个 Outport 是否存在、是否连接到正确的模拟信号源 |
| [`practice.md`](practice.md) | 跟着做的操作练习、常见错误及进阶说明 |

## 运行步骤（零基础）

1. 安装有 **Simulink** 的 MATLAB（本项目未提供安装程序）。
2. 将这里的两个 `.m` 文件下载到同一个空文件夹。
3. 打开 MATLAB，切换「当前文件夹（Current Folder）」到该文件夹。
4. 在「命令窗口（Command Window）」输入：

   ```matlab
   create_outports
   ```

5. 预计会新建并打开 `outport_demo` 模型。检查模块名称及连线。
6. 再输入：

   ```matlab
   check_outports
   ```

7. 根据命令窗口的检查结果，核对 5 路是否一一对应。

如果已有名为 `outport_demo` 的模型，脚本会停止，**不会主动覆盖**。不要为了运行示例直接删除自己的模型；可以先修改脚本里的 `model` 名称，检查脚本的两处模型名是否一致。

## 自己修改一次

- 打开 `create_outports.m`，找到 `signalNames`。
- 在列表里新增 `'Pressure'`，观察脚本会怎样生成第 6 组。
- 再同步修改 `check_outports.m` 中的 `signalNames`，重新检查。
- 如果要重新生成，请使用新的模型名称，或确认原演示文件不需要后再自行处理。

**重要：** 当前示例用一个 Constant 对应一个 Outport。真正处理「一个已有子系统有几十个输出端口」时，还必须先确认**源模块的每个输出端口序号与目标 Outport 名称的对应关系**；只知道名称，脚本并不能自动猜出该连哪一路。详见 [practice.md](practice.md)。

## 与 CSDN 文章的分工

- **CSDN 第04期**：讲清楚为什么做、`add_block` / `set_param` / `add_line` 是什么意思。
- **本 GitHub 项目**：提供可保存的原创脚本、检查脚本和动手题，不重复整篇文章。
- 第04期文章链接：**待 CSDN 正式发布后补充**。此前相关文章见 [第03期：Excel 通信协议整理](https://blog.csdn.net/qian123456wang/article/details/168873109)。

## 验证状态与使用边界

- `create_outports.m`、`check_outports.m`：**已做代码静态检查，尚未在 MATLAB R2022b / R2024b 中运行验证**。
- 命令窗口的 `OK` 只代表检查脚本检测到预期模块和连接，不代表真实信号或控制功能已通过测试。
- 示例名称和数值均为独立设计的虚构数据，不包含企业模型、协议、设备日志或付费课程资料。
- 不适用于直接修改真实工程。先在独立演示模型中练习，再根据具体模型结构做备份和检查。
