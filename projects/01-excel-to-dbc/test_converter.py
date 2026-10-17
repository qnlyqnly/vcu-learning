"""无需安装额外依赖的入门自测：python test_converter.py"""
import copy
import unittest
from pathlib import Path
from excel_to_dbc import load_workbook, create_dbc

ROOT = Path(__file__).resolve().parent


class ExcelToDBCChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = load_workbook(ROOT / '标准通信矩阵模板.xlsx')

    def test_demo_messages_and_signals(self):
        dbc = create_dbc(self.data)
        self.assertEqual(sum(line.startswith('BO_ ') for line in dbc.splitlines()), 2)
        self.assertEqual(sum(line.startswith(' SG_ ') for line in dbc.splitlines()), 7)

    def test_standard_id(self):
        dbc = create_dbc(self.data)
        self.assertIn('BO_ 384 VCU_DemoStatus: 8 VCU', dbc)

    def test_extended_id(self):
        dbc = create_dbc(self.data)
        self.assertIn(f'BO_ {0x18FF0101 | 0x80000000} MCU_DemoFeedback: 8 MCU', dbc)

    def test_intel_signed_signal(self):
        dbc = create_dbc(self.data)
        self.assertIn('SG_ MotorTorque : 16|16@1- (0.1,0)', dbc)

    def test_overlap_is_rejected(self):
        data = copy.deepcopy(self.data)
        data['Signals'][1]['StartBit'] = '8'
        with self.assertRaisesRegex(ValueError, '重叠'):
            create_dbc(data)

    def test_motorola_is_rejected_not_silently_changed(self):
        data = copy.deepcopy(self.data)
        data['Signals'][0]['ByteOrder'] = 'Motorola'
        with self.assertRaisesRegex(ValueError, '仅支持 Intel'):
            create_dbc(data)

    def test_out_of_range_id_is_rejected(self):
        data = copy.deepcopy(self.data)
        data['Messages'][0]['ID'] = '0x18FF0101'
        with self.assertRaisesRegex(ValueError, '超出 Standard 范围'):
            create_dbc(data)

    def test_bad_signal_start_is_rejected(self):
        data = copy.deepcopy(self.data)
        data['Signals'][0]['StartBit'] = '60'
        with self.assertRaisesRegex(ValueError, '超出报文长度'):
            create_dbc(data)


if __name__ == '__main__':
    unittest.main(verbosity=2)
