#!/usr/bin/env python3
"""Independent reference check; does not execute MATLAB or Simulink."""
from pathlib import Path
import csv
from collections import Counter
root = Path(__file__).resolve().parents[1]
rows = list(csv.DictReader((root / "data/ecu_signal_catalog.csv").open(encoding="utf-8")))
assert len(rows) == 11
assert len({r["SignalName"] for r in rows}) == 11
assert len({r["ECU"] for r in rows}) == 7
assert Counter(r["ECU"] for r in rows) == {"ABS":3,"BMS":2,"MCU":2,"BCM":1,"DCDC":1,"OBC":1,"TBOX":1}
assert all(r["Direction"] == "Input" for r in rows)
assert all(r["DataType"] in {"boolean","uint8","int16","uint16","single","double"} for r in rows)
assert all(r["SignalName"].startswith(r["ECU"] + "_") for r in rows)
q = 0
trace = []
for k in range(101):
    t = k / 10
    s, r = int(1 <= t < 2), int(6 <= t < 7)
    if s and r: raise ValueError("S and R simultaneously active")
    if s: q = 1
    elif r: q = 0
    trace.append((t,s,r,q))
assert [x[3] for x in trace] == [int(1 <= x[0] < 6) for x in trace]
out = root / "outputs"; out.mkdir(exist_ok=True)
with (out / "rs_flipflop_reference.csv").open("w",newline="",encoding="utf-8") as f:
    w = csv.writer(f); w.writerow(["TimeS","SetInputS","ResetInputR","OutputQ"]); w.writerows(trace)
print("PASS: Python RS reference: 101 samples (0..10 s, step 0.1 s)")
print("PASS: CSV catalog: 11 unique signals, 7 ECU groups, all Input")
print("MATLAB/Simulink were not executed.")
