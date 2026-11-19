"""Independent analytic/timeline oracle, NOT an interpreter for MATLAB files.

python tools/check_reference.py            # check the reference contracts
python tools/check_reference.py --write    # also save clearly labelled CSVs
Uses Python standard library only. No vehicle connection or file upload.
"""
from __future__ import annotations

import argparse
import csv
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCENARIOS = (
    "normal", "low_voltage", "neg_stuck", "permit_removed", "pos_stuck",
    "pre_stuck", "pre_open_stuck", "neg_feedback_loss", "ready_feedback_loss",
    "request_removed", "abort_requested", "mcu_not_ready",
)
NAMES = ("OFF", "CLOSE_NEG", "PRECHARGE", "CLOSE_POS", "HV_READY", "FAULT")


def parameters():
    """Read literal teaching parameters; never execute MATLAB source."""
    text = (ROOT / "examples/demo_parameters.m").read_text(encoding="utf-8")
    p = {}
    for name, value in re.findall(r"^p\.(\w+)\s*=\s*([0-9.]+);", text, re.M):
        p[name] = float(value)
    for name in ("closeDelayS", "openDelayS", "closeTimeoutS"):
        value = re.search(r"p\." + name + r"\s*=\s*\[([^]]+)\]", text)
        p[name] = [float(x) for x in value[1].split(",")]
    return p


def reference(p, scenario):
    """Derive event deadlines first; build a sampled physical trace second.

    This does not implement the MATLAB state-switch code. The baseline
    successful path follows an independently calculated event schedule.
    Fault injections truncate that schedule at their specified deadlines.
    """
    dt = p["dtS"]
    ticks = lambda x: math.ceil(x / dt - 1e-9)
    close = list(map(ticks, p["closeDelayS"]))
    opened = list(map(ticks, p["openDelayS"]))
    timeout = list(map(ticks, p["closeTimeoutS"]))
    req = ticks(p["requestOnS"])
    neg = req + close[0]
    pre = neg + close[1]
    t_threshold = -p["resistanceOhm"] * p["capacitanceF"] * math.log1p(-p["completeRatio"])
    pos_cmd = pre + ticks(t_threshold)
    pos = pos_cmd + close[2]
    pre_off = pos + opened[1]
    ready = pre_off
    inf = math.inf
    fault_at, fault_code = inf, "NONE"
    charging = True
    if scenario == "low_voltage":
        charging = False
        pos_cmd = pos = pre_off = ready = inf
        fault_at, fault_code = pre + ticks(p["prechargeTimeoutS"]), "PRECHARGE_TIMEOUT"
    elif scenario == "neg_stuck":
        neg = pre = pos_cmd = pos = pre_off = ready = inf
        fault_at, fault_code = req + timeout[0], "NEG_CLOSE_TIMEOUT"
    elif scenario == "pre_stuck":
        pre = pos_cmd = pos = pre_off = ready = inf
        fault_at, fault_code = neg + timeout[1], "PRE_CLOSE_TIMEOUT"
    elif scenario == "pos_stuck":
        pos = pre_off = ready = inf
        fault_at, fault_code = pos_cmd + timeout[2], "POS_CLOSE_TIMEOUT"
    elif scenario == "pre_open_stuck":
        pre_off = ready = inf
        fault_at, fault_code = pos + ticks(p["preOpenTimeoutS"]), "PRE_OPEN_TIMEOUT"
    elif scenario in ("permit_removed", "request_removed", "abort_requested"):
        fault_at, fault_code = ticks(1), "ABORTED"
    elif scenario == "neg_feedback_loss":
        fault_at, fault_code = ticks(1), "NEG_FEEDBACK_LOST"
    elif scenario == "ready_feedback_loss":
        fault_at, fault_code = ticks(4), "READY_FEEDBACK_LOST"

    # Reject delay beyond its own deadline even in the nominal schedule.
    if scenario in ("normal", "mcu_not_ready"):
        assert close[0] <= timeout[0] and close[1] <= timeout[1]
        assert close[2] <= timeout[2]
        assert ticks(t_threshold) <= ticks(p["prechargeTimeoutS"])
        assert opened[1] <= ticks(p["preOpenTimeoutS"])

    trace = []
    charged_samples = 0
    main_ever_closed = False
    old_fb = [False, False, False]
    tau = p["resistanceOhm"] * p["capacitanceF"]
    for k in range(math.floor(p["durationS"] / dt + 1e-9) + 1):
        if k and old_fb[0] and old_fb[1] and not old_fb[2] and charging:
            charged_samples += 1
        active = k < fault_at
        cmds = [req <= k and active, neg <= k < pos and active, pos_cmd <= k and active]
        fbs = [neg <= k < fault_at + opened[0],
               pre <= k < min(pre_off, fault_at + opened[1]),
               pos <= k < fault_at + opened[2]]
        # No contact can confirm after its command was cancelled.
        if neg >= fault_at:
            fbs[0] = False
        if pre >= fault_at:
            fbs[1] = False
        if pos >= fault_at:
            fbs[2] = False
        if scenario == "pre_open_stuck" and k >= pre:
            fbs[1] = True
        if scenario == "neg_feedback_loss" and k >= ticks(1):
            fbs[0] = False
        if scenario == "ready_feedback_loss" and k >= ticks(4):
            fbs[2] = False
        if fbs[0] and fbs[2]:
            main_ever_closed = True
        u = p["batteryV"] * (1-math.exp(-charged_samples*dt/tau)) if charging else 0.0
        if main_ever_closed:
            u = p["batteryV"]
        state = 0
        for deadline, target in ((req, 1), (neg, 2), (pos_cmd, 3), (ready, 4)):
            if k >= deadline:
                state = target
        if not active:
            state = 5
        is_ready = state == 4 and fbs[0] and fbs[2] and not fbs[1]
        mcu = scenario != "mcu_not_ready"
        current = (p["batteryV"]-u)/p["resistanceOhm"] if (
            fbs[0] and fbs[1] and not fbs[2] and charging) else 0.0
        trace.append(dict(
            TimeS=round(k*dt, 10), StateCode=state, State=NAMES[state],
            VcuHvReq=int(k >= req and not (scenario == "request_removed" and k >= ticks(1))),
            HvPermit=int(not (scenario == "permit_removed" and k >= ticks(1))),
            AbortReq=int(scenario == "abort_requested" and k >= ticks(1)),
            MainNegCmd=int(cmds[0]), PrechargeCmd=int(cmds[1]), MainPosCmd=int(cmds[2]),
            MainNegFb=int(fbs[0]), PrechargeFb=int(fbs[1]), MainPosFb=int(fbs[2]),
            UbattV=p["batteryV"], UbusV=u, VoltageRatio=u/p["batteryV"], IpreA=current,
            HvReady=int(is_ready), McuHvOk=1, McuDriveReady=int(mcu),
            DriveReady=int(is_ready and mcu), FaultCode=fault_code if not active else "NONE",
        ))
        old_fb = fbs
    return trace


def check_trace(rows, p):
    """Safety relationships are specifications, not assertions about MATLAB execution."""
    fault_seen = False
    old_pos = False
    for r in rows:
        assert not r["PrechargeCmd"] or r["MainNegFb"]
        assert not r["MainPosCmd"] or (r["MainNegFb"] and r["VoltageRatio"] >= p["completeRatio"])
        if r["MainPosCmd"] and not old_pos:
            assert r["PrechargeFb"]
        assert not (r["MainPosCmd"] and not r["PrechargeCmd"]) or r["MainPosFb"]
        if r["HvReady"]:
            assert r["MainNegFb"] and r["MainPosFb"] and not r["PrechargeFb"]
            assert r["VcuHvReq"] and r["HvPermit"] and not r["AbortReq"]
        if fault_seen or r["State"] == "FAULT":
            fault_seen = True
            assert r["State"] == "FAULT"
            assert not any(r[x] for x in ("MainNegCmd", "PrechargeCmd", "MainPosCmd", "HvReady"))
        old_pos = bool(r["MainPosCmd"])


def write_csv(path, rows):
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def main(write=False):
    p = parameters()
    lines = ["Python analytic/timeline reference checks. NOT MATLAB execution."]
    assert abs(p["batteryV"]/p["resistanceOhm"]-6) < 1e-12
    theory = -p["resistanceOhm"]*p["capacitanceF"]*math.log1p(-p["completeRatio"])
    assert abs(theory-2.396585818843) < 1e-10 and theory < p["prechargeTimeoutS"]
    lines.append(f"PASS RC reference: I0=6 A; tau=0.8 s; t95={theory:.12f} s")
    expected = ("NONE", "PRECHARGE_TIMEOUT", "NEG_CLOSE_TIMEOUT", "ABORTED",
                "POS_CLOSE_TIMEOUT", "PRE_CLOSE_TIMEOUT", "PRE_OPEN_TIMEOUT",
                "NEG_FEEDBACK_LOST", "READY_FEEDBACK_LOST", "ABORTED", "ABORTED", "NONE")
    summary = []
    normal = None
    for scenario, fault in zip(SCENARIOS, expected):
        rows = reference(p, scenario)
        check_trace(rows, p)
        assert rows[-1]["FaultCode"] == fault
        assert rows[-1]["State"] == ("HV_READY" if fault == "NONE" else "FAULT")
        if scenario in ("low_voltage", "neg_stuck", "pre_stuck", "permit_removed",
                        "request_removed", "abort_requested", "neg_feedback_loss"):
            assert not any(r["MainPosCmd"] or r["HvReady"] for r in rows)
        if scenario == "neg_stuck":
            assert not any(r["PrechargeCmd"] or r["PrechargeFb"] for r in rows)
        if scenario == "pos_stuck":
            assert any(r["MainPosCmd"] for r in rows) and not any(r["MainPosFb"] for r in rows)
        if scenario == "pre_open_stuck":
            assert rows[-1]["PrechargeFb"] and not any(r["HvReady"] for r in rows)
        if scenario == "ready_feedback_loss":
            assert any(r["HvReady"] for r in rows) and not rows[-1]["HvReady"]
        if scenario == "mcu_not_ready":
            assert rows[-1]["HvReady"] and not any(r["DriveReady"] for r in rows)
        ready_at = next((r["TimeS"] for r in rows if r["HvReady"]), "NaN")
        fault_at = next((r["TimeS"] for r in rows if r["State"] == "FAULT"), "NaN")
        summary.append(dict(Scenario=scenario, FinalState=rows[-1]["State"],
                            FaultCode=fault, ReadyTimeS=ready_at, FaultTimeS=fault_at,
                            Evidence="Python reference only"))
        lines.append(f"PASS {scenario}: {rows[-1]['State']}; {fault}; ready={ready_at}; fault={fault_at}")
        if scenario == "normal":
            normal = rows
    assert abs(next(r["TimeS"] for r in normal if r["HvReady"])-2.68) < 1e-9
    q = dict(p, closeDelayS=[0.05,0.05,0.30])
    boundary = reference(q,"normal")
    check_trace(boundary, q)
    assert boundary[-1]["HvReady"]
    lines += ["PASS exact POS-feedback deadline reference", "14 reference groups passed (12 scenarios + RC + deadline).",
              "The .m files, MATLAB assertions and Simulink/Stateflow were NOT executed."]
    print("\n".join(lines))
    if write:
        write_csv(ROOT / "examples/python_reference_summary.csv", summary)
        write_csv(ROOT / "examples/python_reference_normal.csv", normal)
        (ROOT / "examples/python_reference_check.txt").write_text("\n".join(lines)+"\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    main(parser.parse_args().write)
