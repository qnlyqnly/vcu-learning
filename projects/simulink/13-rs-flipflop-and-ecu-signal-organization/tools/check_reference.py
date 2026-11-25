#!/usr/bin/env python3
"""Independent Issue 13 reference checks. Does not execute MATLAB/Simulink."""
from collections import Counter
import csv
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
with (ROOT/"data"/"ecu_signal_catalog.csv").open(newline="",encoding="utf-8") as f:
    rows=list(csv.DictReader(f))
assert len(rows)==11
assert len({r["SignalName"] for r in rows})==11
assert len({r["ECU"] for r in rows})==7
assert all(r["DataType"] in {"boolean","uint8","int16","single","double"} for r in rows)

# Active-high RS: S sets, R resets, neither holds. Simultaneous input is invalid.
t=[round(i/10,1) for i in range(81)]
s=[int(1<=x<2) for x in t]
r=[int(6<=x<7) for x in t]
q=[0]*len(t)
for i in range(1,len(t)):
    if s[i] and r[i]: raise AssertionError("S and R active together")
    q[i]=1 if s[i] else (0 if r[i] else q[i-1])
at=lambda x:t.index(x)
assert (q[at(0)],q[at(1)],q[at(2)],q[at(5.9)],q[at(6)],q[at(7)],q[-1])==(0,1,1,1,0,0,0)
assert [r["ECU"] for r in rows]
counts=Counter(x["ECU"] for x in rows)
with (ROOT/"examples"/"ecu_signal_summary_reference.csv").open("w",newline="",encoding="utf-8") as f:
    w=csv.writer(f); w.writerow(["ECU","SignalCount"]); w.writerows(sorted(counts.items()))
with (ROOT/"examples"/"rs_flipflop_reference.csv").open("w",newline="",encoding="utf-8") as f:
    w=csv.writer(f); w.writerow(["TimeS","SetS","ResetR","OutputQ"]); w.writerows(zip(t,s,r,q))
print("RS set/hold/reset sequence: PASS")
print("ECU catalog: 11 unique signals across 7 ECU groups: PASS")
print("MATLAB/Simulink execution: NOT TESTED")
