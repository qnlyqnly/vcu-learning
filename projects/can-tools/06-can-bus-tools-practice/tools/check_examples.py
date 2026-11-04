#!/usr/bin/env python3
"""Read-only checks for the fictional episode 06 CSV files. Python 3.9+."""
import argparse
import csv
import math
import re
from collections import defaultdict
from pathlib import Path


def read_rows(path, columns):
    with path.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != columns:
            raise ValueError(f"{path.name}: unexpected header")
        rows = list(reader)
    if not rows:
        raise ValueError(f"{path.name}: empty table")
    for number, row in enumerate(rows, 2):
        if None in row or any(value is None for value in row.values()):
            raise ValueError(f"{path.name}:{number}: wrong column count")
    return rows


def check_frames(path):
    columns = ["time_ms", "channel", "direction", "frame_type",
               "can_id", "dlc", "data_hex"]
    rows = read_rows(path, columns)
    groups = defaultdict(list)
    previous = -math.inf
    for number, row in enumerate(rows, 2):
        try:
            time_ms = float(row["time_ms"])
            if not math.isfinite(time_ms) or time_ms < 0 or time_ms < previous:
                raise ValueError("time must be finite, nonnegative and ordered")
            if not row["channel"].strip() or row["direction"] not in ("Rx", "Tx"):
                raise ValueError("invalid channel or direction")
            if row["frame_type"] not in ("STD", "EXT"):
                raise ValueError("frame_type must be STD or EXT")
            if not re.fullmatch(r"0x[0-9A-Fa-f]+", row["can_id"]):
                raise ValueError("can_id must start with 0x")
            can_id = int(row["can_id"], 16)
            limit = 0x7FF if row["frame_type"] == "STD" else 0x1FFFFFFF
            if not 0 <= can_id <= limit:
                raise ValueError("CAN ID out of range")
            if not re.fullmatch(r"[0-8]", row["dlc"]):
                raise ValueError("classic data frame DLC must be 0..8")
            data = row["data_hex"].split()
            if len(data) != int(row["dlc"]):
                raise ValueError("DLC does not match byte count")
            if any(not re.fullmatch(r"[0-9A-Fa-f]{2}", byte) for byte in data):
                raise ValueError("each byte must contain two hexadecimal digits")
            key = (row["channel"], row["direction"], row["frame_type"], can_id)
            groups[key].append(time_ms)
            previous = time_ms
        except ValueError as error:
            raise ValueError(f"{path.name}:{number}: {error}") from error
    print(f"Frames OK: {len(rows)} rows, {len(groups)} groups")
    for key, times in sorted(groups.items()):
        gaps = [round(b - a, 6) for a, b in zip(times, times[1:])]
        print(f"{key[0]} {key[1]} {key[2]} 0x{key[3]:X}: gaps_ms={gaps}")


def check_termination(path):
    rows = read_rows(path, ["case", "resistors_ohm", "expected_ohm", "note"])
    seen = set()
    for number, row in enumerate(rows, 2):
        try:
            if not row["case"] or row["case"] in seen:
                raise ValueError("case name must be nonempty and unique")
            values = [float(item) for item in row["resistors_ohm"].split()]
            expected = float(row["expected_ohm"])
            if not values or any(not math.isfinite(v) or v <= 0 for v in values):
                raise ValueError("resistors must be finite and positive")
            if not math.isfinite(expected) or expected <= 0:
                raise ValueError("expected resistance must be finite and positive")
            result = 1 / sum(1 / value for value in values)
            if not math.isclose(result, expected, rel_tol=1e-9, abs_tol=1e-6):
                raise ValueError(f"expected {expected}, calculated {result}")
            seen.add(row["case"])
            print(f"{row['case']}: {result:.6f} ohm (theory)")
        except (ValueError, ZeroDivisionError, OverflowError) as error:
            raise ValueError(f"{path.name}:{number}: {error}") from error
    print(f"Termination OK: {len(rows)} theoretical cases")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--examples", type=Path,
                        default=Path(__file__).resolve().parents[1] / "examples",
                        help="directory containing the two episode CSV files")
    args = parser.parse_args()
    try:
        check_frames(args.examples / "can_frames.csv")
        check_termination(args.examples / "termination_cases.csv")
    except (OSError, UnicodeError, csv.Error, ValueError) as error:
        print(f"ERROR: {error}")
        return 1
    print("Offline checks only; no device or bus-health validation.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
