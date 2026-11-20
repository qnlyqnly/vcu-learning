#!/usr/bin/env python3
"""Independent standard-library reference checks for Issue 12.
This script does NOT execute or validate the MATLAB files.
"""
from pathlib import Path
import csv
import math
import random
import statistics

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / "examples"
EXAMPLES.mkdir(exist_ok=True)

# Debounce reference: deterministic 1 ms input, 10 consecutive samples.
ts = 0.001
stop = 0.80
on_time = 0.150
off_time = 0.450
bounce = 0.010
debounce_time = 0.010
n = int(round(stop / ts)) + 1
times = [i * ts for i in range(n)]
intended = [1 if on_time <= t < off_time else 0 for t in times]
raw = intended[:]

for i, t in enumerate(times):
    if on_time <= t < on_time + bounce:
        phase = int(math.floor((t - on_time) / (2 * ts) + 1e-10))
        raw[i] = phase % 2
    if off_time <= t < off_time + bounce:
        phase = int(math.floor((t - off_time) / (2 * ts) + 1e-10))
        raw[i] = 1 - (phase % 2)

required = int(math.ceil(debounce_time / ts - 1e-12))
debounced = [0] * n
candidate = raw[0]
count = 1
debounced[0] = raw[0]
for k in range(1, n):
    if raw[k] == candidate:
        count += 1
    else:
        candidate = raw[k]
        count = 1
    debounced[k] = debounced[k - 1]
    if candidate != debounced[k - 1] and count >= required:
        debounced[k] = candidate

edges = [times[i] for i in range(1, n) if debounced[i] != debounced[i-1]]
assert len(edges) == 2, f"Expected 2 output edges, got {edges}"
assert abs(edges[0] - 0.169) < 1e-9, edges
assert abs(edges[1] - 0.469) < 1e-9, edges
assert all(debounced[i] == 0 for i,t in enumerate(times)
           if on_time <= t < on_time+bounce)
assert all(debounced[i] == 1 for i,t in enumerate(times)
           if off_time <= t < off_time+bounce)

with (EXAMPLES / "debounce_reference.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["TimeS", "IntendedState", "RawInput", "DebouncedOutput"])
    w.writerows(zip(times, intended, raw, debounced))

# Low-pass reference: exact first-order discrete coefficient.
filter_ts = 0.001
filter_stop = 2.0
tau = 0.025
signal_freq = 1.5
interference_freq = 30.0
interference_amp = 0.25
noise_std = 0.12
rng = random.Random(12)
m = int(round(filter_stop / filter_ts)) + 1
ft = [i * filter_ts for i in range(m)]
clean = [math.sin(2 * math.pi * signal_freq * t) for t in ft]
noise = [noise_std * rng.gauss(0, 1) for _ in ft]
interference = [interference_amp * math.sin(2 * math.pi * interference_freq * t)
                for t in ft]
noisy = [c + h + z for c,h,z in zip(clean, interference, noise)]
a = math.exp(-filter_ts / tau)

filtered = [noisy[0]]
filtered_clean = [clean[0]]
for k in range(1, m):
    filtered.append(a * filtered[-1] + (1-a) * noisy[k])
    filtered_clean.append(a * filtered_clean[-1] + (1-a) * clean[k])

raw_residual = [noisy[i] - clean[i] for i in range(m)]
filtered_residual = [filtered[i] - filtered_clean[i] for i in range(m)]
settle = [i for i,t in enumerate(ft) if t >= 0.25]
raw_std = statistics.pstdev([raw_residual[i] for i in settle])
filtered_std = statistics.pstdev([filtered_residual[i] for i in settle])
assert 0 < a < 1
assert filtered_std < raw_std, (raw_std, filtered_std)
ratio = filtered_std / raw_std
assert ratio < 0.65, ratio

with (EXAMPLES / "filter_reference.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["TimeS","CleanSignal","NoisyInput","FilteredOutput",
                "FilteredCleanReference","RawResidual","FilteredResidual"])
    w.writerows(zip(ft, clean, noisy, filtered, filtered_clean,
                    raw_residual, filtered_residual))

summary = (
    "Independent Python reference check (standard library only)\n"
    "This script computes the specification independently; it does not execute MATLAB.\n\n"
    f"Debounce sample time: {ts:.3f} s\n"
    f"Required stable samples: {required}\n"
    f"Accepted ON edge: {edges[0]:.3f} s\n"
    f"Accepted OFF edge: {edges[1]:.3f} s\n"
    "Debounce output transitions: 2 (PASS)\n"
    "Transient ON/OFF bounce ignored: PASS\n\n"
    f"Filter sample time: {filter_ts:.3f} s\n"
    f"Time constant: {tau:.3f} s\n"
    f"Coefficient a=exp(-Ts/tau): {a:.9f}\n"
    f"Raw residual standard deviation after 0.25 s: {raw_std:.6f}\n"
    f"Filtered residual standard deviation after 0.25 s: {filtered_std:.6f}\n"
    f"Residual ratio: {ratio:.4f} (<0.65 PASS)\n\n"
    "Result: Python reference checks passed.\n"
    "MATLAB execution and Simulink/Stateflow model execution remain unverified.\n"
)
(EXAMPLES / "python_reference_check.txt").write_text(summary, encoding="utf-8")
print(summary)
