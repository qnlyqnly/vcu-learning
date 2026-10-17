# vcu-learning 项目协作约定

> 该仓库用于个人原创 VCU / 车载 CAN / DBC 学习实验。

## 当前目标

在账号 `qnlyqnly` 下创建仓库 `vcu-learning`，**必须为 Private（私有）**，将现有源码、Excel 模板、示例 DBC、README、测试及文档推送到默认分支。仓库公开前必须获得所有者明确审核同意。

## 初次上传与核验

1. 若仓库不存在，仅在具有账号授权写入的环境中创建 **Private** 仓库。不得默认 Public。
2. 推送本项目文件，排除 `__pycache__`、`.pyc`、本地密钥或任何用户工作资料。
3. 检查 README 和 `projects/01-excel-to-dbc/README.md` 的相对链接。
4. 先进入 `projects/01-excel-to-dbc` 目录，再运行 `python -m unittest -v test_converter.py`，报告成功/失败的实际输出。
5. 仓库维持私有；不要自动转公开；不要代发 CSDN。

## 原创与保密

- 只使用虚构的教学用报文，不引用任何雇主、客户内部通讯协议、量产模型、标定参数或商业秘密。
- 不复制付费课程源码、模型、截图、文案。
- 测试通过只能称“离线 Python 测试通过”，不得冒充 CANdb++ 实测或真实 ECU 联调。
- 若需要扩展到 Simulink，先独立设计模型并在有授权的 MATLAB 环境运行后再发布结果。
