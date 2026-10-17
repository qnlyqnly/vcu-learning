#!/usr/bin/env python3
"""Excel 通信矩阵 -> 简明 CAN DBC 演示转换器。

适用：经典 CAN，11/29 位 ID，Intel 小端，整型有/无符号，单路信号。
无第三方依赖（仅 Python 标准库），不支持 Motorola / CAN FD / 复用信号。
"""
from __future__ import annotations

import argparse
import math
import re
from collections import defaultdict
from pathlib import Path
from xml.etree import ElementTree as ET
from zipfile import ZipFile

NS = {'x': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
      'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
      'p': 'http://schemas.openxmlformats.org/package/2006/relationships'}
IDENT = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*$')


def _col_index(ref: str) -> int:
    letters = re.match(r'[A-Z]+', ref)
    if not letters:
        raise ValueError(f'错误单元格坐标: {ref}')
    n = 0
    for char in letters.group():
        n = n * 26 + ord(char) - ord('A') + 1
    return n - 1


def _load_sheet(zf: ZipFile, path: str, strings: list[str]) -> list[dict[str, str]]:
    root = ET.fromstring(zf.read(path))
    lines = []
    for row in root.findall('.//x:sheetData/x:row', NS):
        data = {}
        for cell in row.findall('x:c', NS):
            typ = cell.get('t')
            if typ == 'inlineStr':
                val = ''.join(t.text or '' for t in cell.findall('.//x:is/x:t', NS))
            else:
                v = cell.find('x:v', NS)
                if v is None:
                    val = ''
                elif typ == 's':
                    val = strings[int(v.text or '0')]
                else:
                    val = v.text or ''
            if val != '':
                data[_col_index(cell.get('r', 'A1'))] = str(val).strip()
        if data:
            lines.append(data)
    if not lines:
        return []
    headers = lines[0]
    return [{h: row.get(i, '') for i, h in headers.items() if h} for row in lines[1:] if any(row.values())]


def load_workbook(file: Path) -> dict[str, list[dict[str, str]]]:
    with ZipFile(file) as zf:
        names = set(zf.namelist())
        strings = []
        if 'xl/sharedStrings.xml' in names:
            shared = ET.fromstring(zf.read('xl/sharedStrings.xml'))
            for si in shared.findall('x:si', NS):
                strings.append(''.join(t.text or '' for t in si.findall('.//x:t', NS)))
        workbook = ET.fromstring(zf.read('xl/workbook.xml'))
        rels = ET.fromstring(zf.read('xl/_rels/workbook.xml.rels'))
        links = {rel.get('Id'): rel.get('Target') for rel in rels}
        sheets = {}
        for sheet in workbook.findall('x:sheets/x:sheet', NS):
            name = sheet.get('name')
            if name not in {'Messages', 'Signals'}:
                continue
            rid = sheet.get(f'{{{NS["r"]}}}id')
            target = links.get(rid, '')
            if target.startswith('/xl/'):
                target = target[1:]
            elif target.startswith('xl/'):
                pass
            else:
                target = 'xl/' + target.lstrip('/')
            if '..' in target.split('/'):
                raise ValueError('工作表引用异常')
            sheets[name] = _load_sheet(zf, target, strings)
        return sheets


def required(row: dict[str, str], field: str, context: str) -> str:
    value = row.get(field, '').strip()
    if not value:
        raise ValueError(f'{context}：缺少 {field}')
    return value


def name_check(value: str, context: str) -> str:
    if not IDENT.fullmatch(value):
        raise ValueError(f'{context}：名称 {value!r} 不合法（仅英文、数字和下划线；不能数字开头）')
    return value


def parse_integer(value: str, context: str) -> int:
    try:
        x = float(value)
        if not x.is_integer():
            raise ValueError()
        return int(x)
    except (ValueError, OverflowError):
        raise ValueError(f'{context} 必须是整数，实际为 {value!r}') from None


def fmt(number: float) -> str:
    return format(number, '.12g')


def create_dbc(sheets: dict[str, list[dict[str, str]]]) -> str:
    if not sheets.get('Messages') or not sheets.get('Signals'):
        raise ValueError('必须包含 Messages 和 Signals 两个有数据的工作表')
    messages = {}
    used_ids = set()
    nodes = set()
    for n, row in enumerate(sheets['Messages'], 2):
        ctx = f'Messages 第{n}行'
        name = name_check(required(row, 'Name', ctx), ctx)
        if name in messages:
            raise ValueError(f'{ctx}：报文名重复 {name}')
        raw_id = required(row, 'ID', ctx)
        try:
            can_id = int(raw_id, 16) if raw_id.lower().startswith('0x') else parse_integer(raw_id, ctx+' ID')
        except ValueError as e:
            raise ValueError(f'{ctx}：ID格式错误，请用0x开头的十六进制或十进制，例如 0x180') from e
        typ = required(row, 'FrameType', ctx)
        if typ not in ('Standard', 'Extended'):
            raise ValueError(f'{ctx}：FrameType 只能是 Standard 或 Extended')
        if not (0 <= can_id <= (0x7FF if typ == 'Standard' else 0x1FFFFFFF)):
            raise ValueError(f'{ctx}：CAN ID 超出 {typ} 范围')
        if (typ, can_id) in used_ids:
            raise ValueError(f'{ctx}：同一帧类型和 ID 重复')
        used_ids.add((typ, can_id))
        dlc = parse_integer(required(row, 'DLC', ctx), ctx+' DLC')
        if not (1 <= dlc <= 8):
            raise ValueError(f'{ctx}：本示例仅支持经典 CAN，DLC=1~8')
        sender = name_check(required(row, 'Sender', ctx), ctx)
        cycle = parse_integer(required(row, 'CycleMs', ctx), ctx+' CycleMs')
        if not (0 <= cycle <= 65535):
            raise ValueError(f'{ctx}：CycleMs范围是0~65535；0表示未填写周期要求')
        nodes.add(sender)
        dbc_id = can_id | 0x80000000 if typ == 'Extended' else can_id
        messages[name] = dict(dbc_id=dbc_id, dlc=dlc, sender=sender, cycle=cycle, signals=[], occupied=set())

    for n, row in enumerate(sheets['Signals'], 2):
        ctx = f'Signals 第{n}行'
        parent = required(row, 'MessageName', ctx)
        if parent not in messages:
            raise ValueError(f'{ctx}：MessageName {parent!r} 在 Messages 中找不到')
        msg = messages[parent]
        name = name_check(required(row, 'Name', ctx), ctx)
        if any(s['name'] == name for s in msg['signals']):
            raise ValueError(f'{ctx}：同一报文内信号名称重复 {name}')
        start = parse_integer(required(row, 'StartBit', ctx), ctx+' StartBit')
        length = parse_integer(required(row, 'Length', ctx), ctx+' Length')
        if not (0 <= start and 1 <= length <= 64 and start + length <= msg['dlc'] * 8):
            raise ValueError(f'{ctx}：信号位超出报文长度，请检查StartBit、Length和DLC')
        if required(row, 'ByteOrder', ctx) != 'Intel':
            raise ValueError(f'{ctx}：入门版仅支持 Intel（Motorola留到下一期）')
        sign = required(row, 'Signed', ctx)
        if sign not in ('Unsigned', 'Signed'):
            raise ValueError(f'{ctx}：Signed 只能是 Unsigned 或 Signed')
        bits = set(range(start, start + length))
        if bits & msg['occupied']:
            raise ValueError(f'{ctx}：信号 {name} 与同报文已有信号位重叠')
        msg['occupied'].update(bits)
        factor = float(required(row, 'Factor', ctx))
        offset = float(required(row, 'Offset', ctx))
        minimum = float(required(row, 'Min', ctx))
        maximum = float(required(row, 'Max', ctx))
        if not all(math.isfinite(v) for v in (factor, offset, minimum, maximum)) or factor == 0 or minimum > maximum:
            raise ValueError(f'{ctx}：数值必须有限，Factor不能为0，Min不能大于Max')
        # 不自动篡改输入的物理量程，假定用户已核对信号范围
        unit = row.get('Unit', '').strip()
        if '"' in unit or '\n' in unit or '\r' in unit or not unit.isascii():
            raise ValueError(f'{ctx}：单位不能包含中文、双引号或换行（此演示版使用ASCII编码）')
        receiver = name_check(required(row, 'Receiver', ctx), ctx)
        nodes.add(receiver)
        msg['signals'].append(dict(name=name, start=start, length=length, sign='-' if sign == 'Signed' else '+',
                                   factor=factor, offset=offset, minimum=minimum, maximum=maximum,
                                   unit=unit, receiver=receiver))
    for name, m in messages.items():
        if not m['signals']:
            raise ValueError(f'报文 {name} 还没有任何信号')

    lines = ['VERSION ""', '', 'NS_ :', '    NS_DESC_', '    CM_', '    BA_DEF_', '    BA_', '    VAL_', '', 'BS_:', '', 'BU_: ' + ' '.join(sorted(nodes)), '']
    for name, m in messages.items():
        lines.append(f'BO_ {m["dbc_id"]} {name}: {m["dlc"]} {m["sender"]}')
        for s in m['signals']:
            lines.append(f' SG_ {s["name"]} : {s["start"]}|{s["length"]}@1{s["sign"]} '
                         f'({fmt(s["factor"])},{fmt(s["offset"])}) '
                         f'[{fmt(s["minimum"])}|{fmt(s["maximum"])}] "{s["unit"]}" {s["receiver"]}')
        lines.append('')
    lines.extend(['BA_DEF_ BO_ "GenMsgCycleTime" INT 0 65535;',
                  'BA_DEF_DEF_ "GenMsgCycleTime" 0;', ''])
    for m in messages.values():
        if m['cycle'] > 0:
            lines.append(f'BA_ "GenMsgCycleTime" BO_ {m["dbc_id"]} {m["cycle"]};')
    return '\n'.join(lines) + '\n'


def main():
    ap = argparse.ArgumentParser(description='Excel通信矩阵（Messages+Signals）转换成经典CAN DBC')
    ap.add_argument('excel', type=Path, help='输入 .xlsx 文件')
    ap.add_argument('dbc', type=Path, nargs='?', help='输出 .dbc 文件，可省略')
    args = ap.parse_args()
    try:
        source = args.excel
        if not source.is_file():
            raise ValueError(f'找不到Excel文件：{source}')
        output = args.dbc if args.dbc else source.with_suffix('.dbc')
        result = create_dbc(load_workbook(source))
        # 本示例输入按英文协议字段设计，输出ASCII，避免编码兼容问题
        output.write_text(result, encoding='ascii')
        print(f'成功：{output}，共 {sum(line.startswith("BO_ ") for line in result.splitlines())} 条报文、{sum(line.startswith(" SG_ ") for line in result.splitlines())} 个信号')
    except (ValueError, OSError, ET.ParseError, KeyError) as e:
        ap.exit(1, f'转换失败：{e}\n')


if __name__ == '__main__':
    main()
