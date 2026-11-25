#!/usr/bin/env python3
"""Independent reference check; does not execute MATLAB or Simulink."""
from pathlib import Path
import csv
root = Path(__file__).resolve().parents[1]
rows = list(csv.DictReader((root / "data/ecu_signal_catalog.csv").open(encoding="utf-8")))
assert len(rows) == 11
assert len({r["SignalName"] for r in rows}) == 11
assert len({r["ECU"] for r in rows}) == 7
q = 0
trace = []
for t in [0, 1, 2, 6, 7]:
    s, r = int(1 <= t < 2), int(6 <= t < 7)
    if s and r: raise ValueError("S and R simultaneously active")
    if s: q = 1
    elif r: q = 0
    trace.append((t,s,r,q))
assert [x[3] for x in trace] == [0,1,1,0,0]
out = root / "examples"; out.mkdir(exist_ok=True)
with (out / "rs_flipflop_reference.csv").open("w",newline="",encoding="utf-8") as f:
    w = csv.writer(f); w.writerow(["TimeS","S","R","Q"]); w.writerows(trace)
print("Python independent reference checks: PASS")
print("RS sequence: initial 0 -> set 1 -> hold 1 -> reset 0 -> hold 0")
print("ECU catalog: 11 teaching signals across 7 ECU groups")
print("MATLAB/Simulink execution remains unverified.")
