@echo off
chcp 65001 >nul
cd /d "%~dp0"
where py >nul 2>nul
if %errorlevel%==0 (
  py -3 excel_to_dbc.py "标准通信矩阵模板.xlsx" "演示生成.dbc"
) else (
  python excel_to_dbc.py "标准通信矩阵模板.xlsx" "演示生成.dbc"
)
echo.
echo 如果显示转换失败，请根据错误信息检查 Excel 表格。
pause
