# 第05期 · 从空白模型搭一条 From/Goto 信号路径

本练习只用 MATLAB 和 Simulink。Constant 模拟“已经解出的物理信号”，不接 CAN 硬件、不加载 DBC，也不能据此声称 CAN Unpack 已实测。下面的显示和报错都是待运行的预期。

## 1. 新建空白模型

1. 打开 MATLAB，在“主页（Home）”点击 Simulink。
2. 在开始页选择“空白模型（Blank Model）”。
3. 保存为 `FromGoto_Demo.slx`，放在独立练习文件夹，不覆盖已有模型。
4. 将工具栏“停止时间（Stop Time）”设为 `1`。
5. 先在同一层画布完成全部操作；这一关不创建子系统。

## 2. 放入四个模块

双击画布空白处，依次输入下面英文模块名并选择。若快捷搜索未出现，打开“库浏览器（Library Browser）”按路径查找。

| 数量 | 模块 | 库路径 | 本例用途 |
| --- | --- | --- | --- |
| 1 | Constant | Simulink / Sources | 模拟车速12.3 km/h |
| 1 | Goto | Simulink / Signal Routing | 将这路信号送入标签 |
| 1 | From | Simulink / Signal Routing | 从标签取回这路信号 |
| 1 | Display | Simulink / Sinks | 看取回的数值 |

模块名称可以改成 `SpeedSource`、`SpeedGoto`、`SpeedFrom`、`SpeedDisplay`。**模块名称与标签是两项不同设置**；改块名不会自动替你改标签。

## 3. 设参数

1. 双击 Constant，将“常量值（Constant value）”设为 `12.3`，点击“应用（Apply）/确定（OK）”。
2. 双击 Goto，把“Goto 标签（Goto tag）”改成 `Demo_VehicleSpeed`。
3. 把“标签可见性（Tag visibility）”选为 `local`，确认。
4. 双击 From，把“Goto 标签（Goto tag）”同样设为 `Demo_VehicleSpeed`，确认。
5. 字母大小写与下划线保持完全一致；不要把界面显示的方括号手打进标签里。

R2022b/R2024b 的中文翻译与按钮位置可能不同，以旁边英文参数为定位依据。本期未在这两个版本实测。

## 4. 连线并运行

1. 从 Constant 右侧输出端口拖线到 Goto 左侧输入端口。
2. 从 From 右侧输出端口拖线到 Display 左侧输入端口。
3. **不在 Goto 和 From 之间画物理线**，它们通过标签关联。
4. 按 `Ctrl+D` 更新模型；如果报错，先检查标签与是否在同一层。
5. 点击“运行（Run）”。预期 Display 为 `12.3`。
6. 将 Constant 改成 `45.6`，再次运行，预期 Display 变为 `45.6`。

这里没有做Factor换算：Constant填的就是物理值。From/Goto只传递数值，不把12.3变成123，也不发送CAN报文。

## 5. 故意改错，再修好

先保存正确的基线，再每次只做一种修改。

| 操作 | 预期现象 | 怎么恢复 |
| --- | --- | --- |
| 只把From标签改成Demo_VehicleSpeed_X | 名称初筛提示找不到同名Goto；更新模型可能报错 | 改回Demo_VehicleSpeed |
| 删除From，留下Constant→Goto | 名称初筛提示Goto没有同名From；这不一定阻止模型运行 | 撤销删除，再接回Display |
| 复制第二个Goto，标签仍相同 | 初筛提示重复Goto候选；同层local重名需核查 | 删除自己新增的测试块 |
| 将From移入新子系统，Goto仍local且在外层 | 名称初筛仍可能匹配，但实际不可见，更新模型可发现问题 | 先移回同一层，不盲目改global |

最后一行最重要：**同名不等于实际可见**。不同子系统里的合法local标签也可以重名，不能见到重复就自动改名。

## 6. 跑名称初筛

把 `scripts/Check_FromGoto_OrphanTags.m` 放到MATLAB可找到的文件夹，或将Current Folder切到scripts。保持练习模型已加载，在命令窗口执行：

```matlab
report = Check_FromGoto_OrphanTags('FromGoto_Demo');
disp(report(report.IsCandidate, :))
```

函数只读模型，不更新、不保存、不改块。报告解释：

| Finding | 含义 |
| --- | --- |
| NAME_MATCH_ONLY | 在搜索覆盖范围里双方同名；不是“模型通过” |
| FROM_WITHOUT_NAME_MATCH | From未找到同名Goto候选 |
| GOTO_WITHOUT_NAME_MATCH | Goto未找到同名From候选 |
| DUPLICATE_GOTO_NAME | 搜索范围有多个同名Goto，需人工核对作用域 |

搜索不进入掩码内部、库链接内部或引用模型内部，不做变体分析；范围外的匹配可能导致误报。空报告也不表示整个工程没有标签。

## 7. 再加一条Ready

再建一组 Constant→Goto、From→Display，将两个标签都设为 `Demo_Ready`，Goto仍为local。Constant先设1，再设0，预期对应Display同步变化。**每路标量各用一对标签**，不把车速与Ready同时接入一个普通Goto。

做完应能指出：源块在哪里、标签是什么、From在哪一层、消费者是哪个Display。实际版本与结果填入[VALIDATION.md](../VALIDATION.md)。

参考：[Goto](https://www.mathworks.com/help/simulink/slref/goto.html)、[From](https://www.mathworks.com/help/simulink/slref/from.html)、[Goto Tag Visibility](https://www.mathworks.com/help/simulink/slref/gototagvisibility.html)。本练习步骤与虚构名称独立设计。
