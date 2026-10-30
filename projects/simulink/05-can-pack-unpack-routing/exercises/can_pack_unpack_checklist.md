# 第05期 · CAN Pack / CAN Unpack 基础检查清单

先分清方向：**Unpack把报文拆成信号，Pack把信号组成报文。** From/Goto只在模型内传递信号，既不选择CAN通道，也不读DBC。

本页为待操作清单，未在MATLAB R2022b、R2024b或CAN硬件上实测。没有Vehicle Network Toolbox时，先完成From/Goto练习和手算即可。

## 1. 先核对本期定义

| 项目 | 本例约定 |
| --- | --- |
| DBC | 本期dbc/demo_vcu_can.dbc |
| 报文名 | DemoVehicleStatus |
| CAN ID | 0x321 = 十进制801；标准11位帧 |
| 长度 | 8字节，经典CAN数据帧 |
| VehicleSpeed | 起始位0，16bit，Intel，无符号，Factor=0.1，Offset=0 |
| Ready | 起始位16，1bit，Intel，无符号，Factor=1，Offset=0 |
| 编号 | Byte0起、bit0起；Ready在Byte2的最低位 |

第02期同样用了0x321，但定义是1字节报文，**不能混用**。ID相同不代表DBC相同。

- [ ] 用的是本期DBC，不是其他目录的同名/同ID定义。
- [ ] 十六进制0x321没有误填成十进制321。
- [ ] 标准帧/扩展帧、DLC、字节序与信号长度一致。
- [ ] 模块输入输出按实际端口标签核对，不猜“第一个端口一定是车速”。

## 2. 手工拆一条，再装回去

Case3：`C8 01 01 00 00 00 00 00`。

1. Byte0=0xC8=200，Byte1=0x01=1。
2. 原始车速=200+256×1=456。
3. 物理车速=456×0.1+0=45.6 km/h。
4. Ready=Byte2按位与1=1。
5. 反向装包：45.6÷0.1=456；456的低字节C8、高字节01，Ready写Byte2的bit0。

另外两组：

| 用例 | DATA | 车速raw → 物理值 | Ready |
| --- | --- | --- | --- |
| Case1 | 00 00 00 00 00 00 00 00 | 0 → 0.0 km/h | 0 |
| Case2 | 7B 00 01 00 00 00 00 00 | 123 → 12.3 km/h | 1 |
| Case3 | C8 01 01 00 00 00 00 00 | 456 → 45.6 km/h | 1 |

这只是对虚构字节的计算核对，不是CAN Pack/Unpack实测。CSV是人工对照表，不是ASC日志，不能直接宣称可回放。

## 3. 找到对应的模块和工具箱

1. 打开Simulink库浏览器（Library Browser）。
2. 找到 Vehicle Network Toolbox / CAN Communication。
3. 分别找到 CAN Pack 和 CAN Unpack。
4. 若不存在，先核实工具箱是否安装且可用；不要用外观相似的其他厂商模块照抄参数。
5. 本页针对MathWorks这一组模块。其他目标库或ECUCoder模块的报文格式与参数可能不同，不能保证直接互连。

## 4. 手动配置，暂不写自动加载脚本

| 模块 | 主要设置 |
| --- | --- |
| CAN Pack | “数据输入方式（Data input as）”选择基于DBC的CANdb specified signals模式 |
| CAN Unpack | “数据输出方式（Data output as）”选择基于DBC的CANdb specified signals模式 |
| 两者 | “数据库文件（Database file；旧界面可能为CANdb file）”选择本期DBC |
| 两者 | “报文（Message）”选择DemoVehicleStatus，核对ID与8字节长度 |

不同版本字段名称可能变化，以对应版本帮助页和实际界面为准。本页没有验证界面截图或工具箱兼容性。

- [ ] 确认数据库模式使用的是物理值，了解本模块的缩放约定。
- [ ] 已由DBC应用Factor时，不再额外乘0.1；Pack输入12.3，不误填raw值123。
- [ ] 不把CAN Receive/Transmit的控制端口、触发端口误认为普通信号。
- [ ] CAN Pack输出的是报文表示；实际发送由CAN Transmit等模块及通道配置完成。
- [ ] CAN Unpack是解包模块，不能自己采集CAN总线。

## 5. 可选的离线闭环检查（待实际搭建）

仅在已安装相应工具箱时进行，不需要连接实车：

1. 新建独立空白模型，放两个Constant、一个CAN Pack、一个CAN Unpack和两个Display。
2. 按上节配置同一份DBC、同一条DemoVehicleStatus。
3. 将Constant的物理车速12.3接Pack的VehicleSpeed输入，将值1接Ready输入；类型不兼容时先查实际端口要求，不能忽略诊断。
4. 将Pack的报文输出接Unpack的报文输入，Unpack两路信号分别接Display。
5. 按Ctrl+D更新，再运行；预期读回12.3与1。分别改成Case1和Case3再检查。
6. 若界面提供报文数据观察，再核对ID、DLC和已定义位。DBC未定义的剩余位不应被误当成有效业务信号。

Pack→Unpack直接相连只验证软件内的打包/解包链路，**没有CAN通道，也没有真正发送**。图中的接收与发送是架构说明，不要求在真实总线上转发0x321。

## 6. 发生错误时先查

| 现象 | 先核对 |
| --- | --- |
| 数值差10倍 | 输入raw/物理值是否混淆，Factor是否重复使用 |
| 数值明显错位 | Intel/字节序、Start bit、Length |
| 找不到报文 | DBC路径、消息名、是否误用前期文件 |
| From找不到来源 | 标签拼写与Goto作用域，不是去改CAN ID |
| Pack存在但总线没报文 | 是否有发送模块和通道配置；Pack本身不是发送器 |
| CSV有数据但模型没变化 | CSV只是对照表，没有自动注入或回放功能 |

将实际结果和版本填入[VALIDATION.md](../VALIDATION.md)，不要把预期勾选为已完成。

参考：[CAN Pack](https://www.mathworks.com/help/vnt/ug/canpack.html)、[CAN Unpack](https://www.mathworks.com/help/vnt/ug/canunpack.html)。本文为独立设计的核对流程，未复制官方示例模型。
