"""Render exact, labelled engineering UI mockups; NOT MATLAB screenshots.

Requires matplotlib. All plotted values come from the independently checked
Python reference CSV. The six-state layout is an original teaching diagram.
Run from any folder: python path/to/tools/render_figures.py
"""
import csv
import io
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle, FancyBboxPatch
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FIGURES = ROOT / "figures"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                     "svg.fonttype": "none", "svg.hashsalt": "hv11-teaching"})
BG = "#f0f0f0"
BLUE = "#1263a0"


def save_figure(fig, path):
    # Repository-native SVG can be committed in GitHub's text editor.
    fig.savefig(path.with_suffix(".svg"), format="svg", metadata={"Date": None})
    # Indexed PNG keeps exact geometry/data and a small repository footprint.
    buffer = io.BytesIO()
    fig.savefig(buffer, format="png", dpi=120)
    buffer.seek(0)
    with Image.open(buffer) as original:
        original.convert("RGB").quantize(colors=128, dither=Image.Dither.NONE).save(path, optimize=True)


def shell(title, tabs, status):
    fig = plt.figure(figsize=(16, 10), dpi=120, facecolor=BG)
    ui = fig.add_axes([0, 0, 1, 1])
    ui.set_xlim(0, 1600)
    ui.set_ylim(1000, 0)
    ui.axis("off")
    ui.add_patch(Rectangle((0, 0), 1600, 36, color="#dce8f2"))
    ui.text(16, 24, title, fontsize=12, color="#233344")
    ui.text(1475, 24, "_       □       ×", fontsize=12)
    ui.add_patch(Rectangle((0, 36), 1600, 39, color="#fafafa"))
    ui.text(22, 61, tabs, fontsize=11, color="#303030")
    ui.add_patch(Rectangle((0, 75), 1600, 61, color="#e5e5e5"))
    ui.text(22, 103, "↶   ↷     |     +     −     |     Fit to View     |     Signal Names: All", fontsize=10)
    ui.text(22, 125, "EDUCATIONAL UI MOCKUP  •  R2022b-style layout  •  NOT a MATLAB / Simulink run screenshot",
            color="#9a381c", fontsize=11, weight="bold")
    ui.add_patch(Rectangle((0, 965), 1600, 35, color="#e0e0e0"))
    ui.text(16, 988, status, fontsize=10, color="#333333")
    return fig, ui


def state_figure():
    fig, ui = shell("hv_precharge_teaching  —  Simulink / Stateflow style teaching view",
                    "File     Simulation     Debug     Modeling     Format     Apps",
                    "Teaching design only  |  Fixed-step reference: 0.01 s  |  No .slx generated or executed")
    ui.add_patch(Rectangle((0, 138), 232, 825, facecolor="#fafafa", edgecolor="#bbbbbb"))
    ui.text(14, 165, "Library Browser", weight="bold", fontsize=11)
    ui.add_patch(Rectangle((12, 180), 208, 27, facecolor="white", edgecolor="#bbbbbb"))
    ui.text(22, 199, "Search libraries", color="#777777")
    library = ["▾  Simulink", "    ▸  Sources", "    ▸  Sinks", "    ▸  Signal Routing", "    ▸  Discrete",
               "▾  Stateflow", "      Chart", "      State", "      Transition", "", "Model workspace", "  Ubatt = 600 V",
               "  R = 100 ohm", "  C = 0.008 F", "  completeRatio = 0.95", "  timeout = 3.0 s"]
    for i, text in enumerate(library):
        ui.text(15, 238+i*26, text, color="#333333", fontsize=10)
    ui.add_patch(Rectangle((245, 155), 1110, 700, facecolor="white", edgecolor="#acb2b8"))
    ui.text(262, 183, "BMS / HV manager: six-state contactor controller", color=BLUE, fontsize=12)
    ui.add_patch(Rectangle((1370, 155), 215, 700, facecolor="#fbfbfb", edgecolor="#acb2b8"))
    ui.text(1385, 185, "Symbols / Interface", weight="bold")
    symbols = ["Inputs", "VcuHvReq", "HvPermit", "AbortReq", "MainNegFb", "PrechargeFb", "MainPosFb", "UbusV / UbattV", "", "Outputs", "MainNegCmd", "PrechargeCmd", "MainPosCmd", "HvReady", "", "MCU signals", "McuHvOk", "McuDriveReady", "DriveReady"]
    for i, text in enumerate(symbols):
        ui.text(1385, 219+i*28, text, color=BLUE if text in ("Inputs", "Outputs", "MCU signals") else "#333333", fontsize=10)

    def state(x, y, label, body):
        ui.add_patch(FancyBboxPatch((x, y), 260, 140, boxstyle="round,pad=0,rounding_size=9",
                                   facecolor="#fbfcfe", edgecolor="#426985", linewidth=1.5))
        ui.text(x+12, y+26, label, weight="bold", fontsize=12)
        ui.plot([x, x+260], [y+38, y+38], color="#aab8c4", linewidth=1)
        ui.text(x+12, y+60, body, va="top", family="DejaVu Sans Mono", fontsize=10, linespacing=1.6)

    state(295, 255, "OFF", "All commands = 0\nWait for request\nand HV permission")
    state(665, 255, "CLOSE_NEG", "MainNegCmd = 1\nWait for MainNegFb\nTimeout: 0.30 s")
    state(1035, 255, "PRECHARGE", "PrechargeCmd = 1\nConfirm PrechargeFb\nThen RC charge <= 3 s")
    state(1035, 545, "CLOSE_POS", "MainPosCmd = 1\nKeep PRE until PosFb\nThen confirm PRE open")
    state(665, 545, "HV_READY", "NegFb && PosFb\n&& !PrechargeFb\nContinue monitoring")
    state(295, 545, "FAULT", "All commands = 0\nFault latched\nNo automatic retry")

    def arrow(a, b, label, xy, color="#264c68", style="-"):
        ui.add_patch(FancyArrowPatch(a, b, arrowstyle="-|>", mutation_scale=15,
                                    color=color, linewidth=1.5, linestyle=style))
        ui.text(*xy, label, ha="center", va="center", fontsize=9, color=color,
                bbox=dict(facecolor="white", edgecolor="none", pad=2))

    arrow((555,325), (665,325), "Req && Permit", (610,306))
    arrow((925,325), (1035,325), "MainNegFb", (980,306))
    arrow((1165,395), (1165,545), "PrechargeFb\nUbus >= 570 V", (1165,468))
    arrow((1035,615), (925,615), "PosFb\n&& !PreFb", (980,596))
    ui.plot([1165, 1165, 425], [397, 465, 465], color="#b34a3a", linestyle="--", linewidth=1.5)
    arrow((425,465), (425,545), "", (425,500), color="#b34a3a", style="--")
    ui.text(765, 455, "Any active state: abort / timeout / feedback loss", ha="center", fontsize=10,
            color="#a03e30", bbox=dict(facecolor="white", edgecolor="none", pad=3))
    ui.text(272, 724, "Three-contactor topology: Kneg in return path; Kpos || (Kpre + R) in positive path.", fontsize=10)
    ui.text(272, 751, "Command → delayed contactor model → feedback     |     Feedback is never wired directly from command.", fontsize=10)
    ui.text(272, 786, "HvReady = actual HV path ready     |     DriveReady additionally requires MCU HV + drive readiness.", color=BLUE, fontsize=10)
    ui.add_patch(Rectangle((245, 869), 1340, 79, facecolor="white", edgecolor="#bcbcbc"))
    ui.text(261, 893, "Code reference  /  simulate_precharge.m", weight="bold", fontsize=10)
    ui.text(261, 920, "case 3    cmd = [true, ~posConfirmed, true];    % PRE opens only after POS feedback confirmation",
            family="DejaVu Sans Mono", fontsize=10)
    save_figure(fig, FIGURES / "图01_Simulink高压上电状态机.png")
    plt.close(fig)


def scope_axes(fig, position, ylabel):
    ax = fig.add_axes(position, facecolor="#151719")
    ax.tick_params(colors="#333333", labelsize=9)
    for spine in ax.spines.values():
        spine.set_color("#9b9b9b")
    ax.grid(color="#4b4e50", linestyle=":", linewidth=0.7)
    ax.set_xlim(0, 5)
    ax.set_ylabel(ylabel, color="#333333", fontsize=10)
    return ax


def waves(data):
    col = lambda name: [float(r[name]) for r in data]
    t = col("TimeS")
    fig, ui = shell("Scope  —  precharge_reference / Voltage and contactor commands",
                    "File     View     Simulation     Tools     Measurements",
                    "Python analytic reference preview  |  t95 = 2.396586 s after PRE feedback  |  Not MATLAB execution evidence")
    ax = scope_axes(fig, [0.075, 0.50, 0.89, 0.32], "Voltage (V)")
    ax.plot(t,col("UbattV"),color="#ffe35c",linewidth=1.6,label="UbattV = 600 V")
    ax.plot(t,col("UbusV"),color="#54dfec",linewidth=1.8,label="UbusV")
    ax.axhline(570,color="#e88b7c",linestyle="--",linewidth=1,label="95% threshold = 570 V")
    ax.set_ylim(-25,650)
    ax.legend(loc="lower right",facecolor="#262626",edgecolor="#666666",labelcolor="white",fontsize=10)
    y = next(float(r["UbusV"]) for r in data if float(r["TimeS"]) == 2.6)
    ax.plot(2.6,y,"o",color="white",markersize=4)
    ax.annotate(f"First sampled threshold: 2.60 s, {y:.3f} V",xy=(2.6,y),xytext=(0.65,365),
                color="white",arrowprops=dict(arrowstyle="->",color="white"),fontsize=10)
    ax2 = scope_axes(fig, [0.075, 0.29, 0.89, 0.16], "Ipre (A)")
    ax2.plot(t,col("IpreA"),color="#ffb74d",linewidth=1.6)
    ax2.set_ylim(-0.3,6.6)
    ax3 = scope_axes(fig, [0.075, 0.09, 0.89, 0.15], "Cmd lanes\n0 / 1 each")
    for name, offset, color in (("MainNegCmd",4,"#8ee58d"),("PrechargeCmd",2,"#63d9ee"),("MainPosCmd",0,"#ffe35c")):
        ax3.step(t,[v+offset for v in col(name)],where="post",color=color,linewidth=1.5,label=name)
    ax3.set_yticks([0.5,2.5,4.5], ["MainPos", "PRE", "MainNeg"])
    ax3.set_ylim(-0.3,5.5)
    ax3.set_xlabel("Time (s)",color="#333333")
    save_figure(fig, FIGURES / "图02_Scope预充电压变化.png")
    plt.close(fig)

    fig, ui = shell("Scope  —  precharge_reference / Commands versus actual feedback",
                    "File     View     Simulation     Tools     Measurements",
                    "Python reference preview  |  CLOSE delay = 0.05 s  |  OPEN delay = 0.03 s  |  Fault tests are listed in VALIDATION.md")
    relays = [("MainNeg",0.665),("Precharge",0.485),("MainPos",0.305)]
    for name, bottom in relays:
        ax = scope_axes(fig,[0.08,bottom,0.875,0.135],name+"\n0 / 1")
        ax.step(t,col(name+"Cmd"),where="post",color="#ffe35c",linewidth=1.8,label=name+"Cmd")
        ax.step(t,col(name+"Fb"),where="post",color="#54dfec",linestyle="--",linewidth=1.5,label=name+"Fb")
        ax.set_ylim(-0.15,1.25)
        ax.set_yticks([0,1])
        ax.legend(loc="lower right",facecolor="#262626",edgecolor="#666666",labelcolor="white",fontsize=9,ncol=2)
    ax = scope_axes(fig,[0.08,0.125,0.875,0.135],"HvReady\n0 / 1")
    ax.step(t,col("HvReady"),where="post",color="#8ee58d",linewidth=1.8)
    ax.set_ylim(-0.15,1.25)
    ax.set_yticks([0,1])
    ax.axvline(2.68,color="#eeeeee",linestyle=":")
    ax.text(2.77,0.45,"2.68 s: NegFb=1, PosFb=1, PreFb=0",color="white",fontsize=10)
    ax.set_xlabel("Time (s)",color="#333333")
    ui.text(132, 925, "Command reference:  POS Cmd 2.60 s → POS Fb 2.65 s → PRE Cmd OFF 2.65 s → PRE Fb OFF / HvReady 2.68 s",
            fontsize=10, color="#333333")
    save_figure(fig, FIGURES / "图03_继电器控制时序.png")
    plt.close(fig)


if __name__ == "__main__":
    FIGURES.mkdir(exist_ok=True)
    with (ROOT / "examples/python_reference_normal.csv").open(encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    state_figure()
    waves(rows)
    print("Rendered 3 deterministic UI mockups as SVG + PNG; no MATLAB screenshots.")
