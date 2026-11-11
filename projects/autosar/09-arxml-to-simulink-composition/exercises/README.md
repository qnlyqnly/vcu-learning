# 第09期 · 动手练习

## 练习目标

利用独立设计的数据表和自己的 ARXML 文件，完成从架构信息整理到 Simulink Composition 模型创建的过程。

## 第一关：检查 Runnable 数据访问

打开 `examples/component_access_points.csv`。

回答：

1. 哪两项是 Read Data？
2. 哪一项是 Write Data？
3. Read Data 对应什么方向的 Port？
4. Write Data 对应什么方向的 Port？

检查原则：

- 读取输入数据时，核对 R-Port 和对应 Data Element。
- 写入输出数据时，核对 P-Port 和对应 Data Element。
- 检查 Runnable 是否属于正确的 SWC。

## 第二关：检查 Port 初始值

打开 `examples/receiver_init_values.csv`。

检查：

1. 初始值对应哪个 Receiver Port？
2. ComSpec 类型是否正确？
3. 初始值是否符合 Data Element 的定义？
4. 是否错误地把无效值当成正常初始值？

注意：CSV 中的 0 是教学示例，不代表实际车辆标定值。

## 第三关：检查 ADT 与 IDT

打开 `examples/data_type_mapping.csv`。

逐项检查：

- ADT 是否存在？
- 是否有对应 IDT？
- 基础类型是否满足数据表示要求？
- 位宽是否符合数据范围？

## 第四关：检查 Composition 连接

打开 `examples/composition_connections.csv`。

检查：

- 提供端是否为 P-Port？
- 接收端是否为 R-Port？
- 双方是否使用兼容的 Interface？
- Data Element 是否一致？

## 第五关：MATLAB 实操

准备自己的 ARXML 文件。

先执行：

```matlab
addpath(fullfile(pwd, 'scripts'));

[ar, names] = inspect_arxml_compositions( ...
    'VCU_Lab_Composition.arxml');
```

检查输出的 Composition 路径。

再选择正确的序号：

```matlab
[model, status] = create_composition_model( ...
    ar, names, 1);
```

检查模型创建结果。

如果有多个 Composition，不要直接默认选择第一项。

## 第六关：常见问题

| 问题 | 检查方向 |
|---|---|
| ARXML 无法导入 | 文件路径、AUTOSAR版本、依赖文件 |
| 找不到 Composition | 检查 ARXML 是否包含 Composition |
| 模型文件已存在 | 检查同名 SLX 文件和已加载模型 |
| 数据类型错误 | 检查 ADT、IDT 及其引用 |
| 创建失败 | 查看 MATLAB 完整报错信息 |

## 完成标准

- [ ] 能区分 Read Data 和 Write Data。
- [ ] 能检查 Receiver Port 初始值。
- [ ] 能理解 ADT 与 IDT 的对应关系。
- [ ] 能识别 Composition 路径。
- [ ] 能执行模型创建函数。
- [ ] 能记录实际运行结果和错误信息。

尚未实际执行的步骤不能标记为已通过。

