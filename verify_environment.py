#!/usr/bin/env python3
"""Environment & Data Verification Script for Students.
Course: Business Intelligence and Big Data Analysis (01 31 0367 00)
"""
from __future__ import annotations

import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

REQUIRED_PACKAGES = [
    ("pandas", "pandas"),
    ("numpy", "numpy"),
    ("openpyxl", "openpyxl"),
    ("duckdb", "duckdb"),
    ("pyarrow", "pyarrow"),
    ("matplotlib", "matplotlib"),
    ("seaborn", "seaborn"),
    ("plotly", "plotly"),
    ("streamlit", "streamlit"),
    ("jupyterlab", "jupyterlab"),
    ("ipykernel", "ipykernel"),
    ("ipywidgets", "ipywidgets"),
    ("pydantic", "pydantic"),
    ("rich", "rich"),
    ("tabulate", "tabulate"),
]

REQUIRED_VSCODE_EXTENSIONS = [
    "ms-python.python",
    "ms-toolsai.jupyter",
    "ms-toolsai.datawrangler",
]

CASE_RAW_FILES = {
    "case0_europack_bottling": [
        "line_telemetry.csv",
        "stoppage_logs.json",
        "plant_master_data.xlsx",
    ],
    "case1_smartpress_automotive": [
        "sensor_telemetry.csv",
        "maintenance_logs.json",
        "machines_and_shifts.xlsx",
    ],
    "case2_dataco_supply_chain": [
        "order_items_trans.csv",
        "shipment_events.json",
        "master_catalog.xlsx",
    ],
    "case3_nexis_workforce": [
        "shift_production_performance.csv",
        "workforce_events.json",
        "workforce_roster_and_skills.xlsx",
    ],
}


def print_header(title: str) -> None:
    print("\n" + "=" * 68)
    print(f"  {title}")
    print("=" * 68)


def check_python_version() -> bool:
    v = sys.version_info
    in_venv = sys.prefix != getattr(sys, "base_prefix", sys.prefix)
    print(f"  OS Platform      : {platform.system()} {platform.release()} ({platform.machine()})")
    print(f"  Python Version   : {v.major}.{v.minor}.{v.micro}")
    print(f"  Python Executable: {sys.executable}")
    print(f"  Inside .venv     : {'YES (Isolated Environment)' if in_venv else 'NO (Global Python - activate .venv!)'}")

    if (v.major, v.minor) < (3, 11):
        print("  [FAIL] Python 3.11+ is required (3.11, 3.12, or 3.13 recommended).")
        return False
    print("  [OK]   Python version is compatible.")
    return True


def check_packages() -> bool:
    all_ok = True
    missing = []
    for pkg_name, import_name in REQUIRED_PACKAGES:
        try:
            mod = __import__(import_name)
            version = getattr(mod, "__version__", "installed")
            print(f"  [OK]   {pkg_name:<15} ({version})")
        except ImportError:
            print(f"  [FAIL] {pkg_name:<15} MISSING")
            missing.append(pkg_name)
            all_ok = False

    if missing:
        print("\n  To install missing packages, run:")
        print(f"    {sys.executable} -m pip install -r requirements.txt ipykernel")
    return all_ok


def check_and_generate_data(repo_root: Path) -> bool:
    lab02_data = (
        repo_root
        / "03_labs_student_starters"
        / "lab_02_bronze_ingestion_and_profiling"
        / "data"
    )
    ref_dir = repo_root / "05_case_studies_reference_solutions"

    all_present = True
    for case_name, files in CASE_RAW_FILES.items():
        # Check student Lab 02 path first, then instructor reference path
        candidate_dirs = [
            lab02_data / case_name,
            lab02_data / case_name / "bronze",
            ref_dir / case_name / "data" / "bronze",
        ]
        active_dir = None
        for d in candidate_dirs:
            if d.exists() and all((d / f).exists() for f in files):
                active_dir = d
                break

        if active_dir is None:
            # Auto-generate only inside the instructor repository
            gen_script = repo_root / "02_data_generator" / "generate_all_packs.py"
            if gen_script.exists():
                print(f"  [INFO] Generating raw Bronze files for {case_name}...")
                subprocess.run([sys.executable, str(gen_script)], cwd=str(repo_root))
                active_dir = ref_dir / case_name / "data" / "bronze"

        if active_dir and all((active_dir / f).exists() for f in files):
            print(f"  [OK]   {case_name:<30} ({len(files)}/{len(files)} raw files ready)")
        else:
            found = 0
            if active_dir:
                found = sum(1 for f in files if (active_dir / f).exists())
            print(f"  [FAIL] {case_name:<30} ({found}/{len(files)} raw files found)")
            all_present = False

    return all_present


def find_vscode_cli() -> list[str] | None:
    """Locate the VS Code CLI command across Linux, macOS, and Windows."""
    sys_name = platform.system()
    if sys_name == "Windows":
        cmd = shutil.which("code.cmd") or shutil.which("code")
        if cmd:
            return [cmd]
        local_app = os.environ.get("LocalAppData", "")
        candidates = [
            Path(local_app) / "Programs" / "Microsoft VS Code" / "bin" / "code.cmd" if local_app else None,
            Path(r"C:\Program Files\Microsoft VS Code\bin\code.cmd"),
        ]
        for p in candidates:
            if p and p.exists():
                return [str(p)]
        return None

    cmd = shutil.which("code")
    if cmd:
        return [cmd]

    if sys_name == "Darwin":
        candidates = [
            Path("/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"),
            Path.home() / "Applications" / "Visual Studio Code.app" / "Contents" / "Resources" / "app" / "bin" / "code",
        ]
        for p in candidates:
            if p.is_file() and os.access(p, os.X_OK):
                return [str(p)]
        return None

    # Linux fallbacks (including Snap, user-local tarball, and Flatpak)
    candidates = [
        Path("/usr/bin/code"),
        Path("/snap/bin/code"),
        Path("/usr/local/bin/code"),
        Path.home() / ".local" / "bin" / "code",
        Path.home() / ".local" / "opt" / "vscode" / "bin" / "code",
    ]
    for p in candidates:
        if p.is_file() and os.access(p, os.X_OK):
            return [str(p)]

    flatpak = shutil.which("flatpak")
    if flatpak:
        try:
            res = subprocess.run(
                [flatpak, "info", "com.visualstudio.code"],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
            if res.returncode == 0:
                return [flatpak, "run", "com.visualstudio.code"]
        except (OSError, subprocess.TimeoutExpired):
            pass

    return None


def check_vscode_and_extensions() -> tuple[bool, list[str]]:
    """Check VS Code availability and required extensions without failing the script."""
    code_cmd = find_vscode_cli()
    if not code_cmd:
        print("  [WARN] Visual Studio Code ('code' CLI) not found.")
        ext_cmds = "; ".join(f"code --install-extension {ext}" for ext in REQUIRED_VSCODE_EXTENSIONS)
        return False, [
            "Install Visual Studio Code from https://code.visualstudio.com/download (or re-run the setup script).",
            f"Install required VS Code extensions ({', '.join(REQUIRED_VSCODE_EXTENSIONS)}): {ext_cmds}",
        ]

    code_display = " ".join(code_cmd)
    print(f"  [OK]   VS Code CLI                 ({code_display})")

    try:
        res = subprocess.run(
            [*code_cmd, "--list-extensions"],
            capture_output=True,
            text=True,
            timeout=20,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        print(f"  [WARN] Could not query installed VS Code extensions ({exc}).")
        return False, [
            "Open VS Code -> Extensions sidebar and install: ms-python.python, ms-toolsai.jupyter, ms-toolsai.datawrangler."
        ]

    if res.returncode != 0:
        print("  [WARN] Could not query installed VS Code extensions.")
        return False, [
            "Open VS Code -> Extensions sidebar and install: ms-python.python, ms-toolsai.jupyter, ms-toolsai.datawrangler."
        ]

    installed = {line.strip().lower() for line in res.stdout.splitlines() if line.strip()}
    missing_exts: list[str] = []
    for ext in REQUIRED_VSCODE_EXTENSIONS:
        if ext.lower() in installed:
            print(f"  [OK]   {ext:<28} (installed)")
        else:
            print(f"  [WARN] {ext:<28} MISSING")
            missing_exts.append(ext)

    if missing_exts:
        cli_prefix = "flatpak run com.visualstudio.code" if code_cmd[0].endswith("flatpak") else "code"
        steps = [
            f"Install missing VS Code extension '{ext}': {cli_prefix} --install-extension {ext}"
            for ext in missing_exts
        ]
        steps.append("Or install them inside VS Code via the Extensions sidebar (Ctrl+Shift+X / Cmd+Shift+X).")
        return False, steps

    return True, []


def main() -> int:
    repo_root = Path(__file__).resolve().parent

    print_header("1. SYSTEM & PYTHON ENVIRONMENT CHECK")
    py_ok = check_python_version()

    print_header("2. PYTHON LIBRARIES CHECK")
    pkg_ok = check_packages()

    print_header("3. COURSE STRUCTURE & RAW BRONZE DATA CHECK")
    data_ok = check_and_generate_data(repo_root)

    print_header("4. VS CODE & EXTENSIONS CHECK")
    vscode_ok, missing_vscode_steps = check_vscode_and_extensions()

    print_header("SUMMARY")
    core_ok = py_ok and pkg_ok and data_ok
    if core_ok and vscode_ok:
        print("  SUCCESS! Your laptop is 100% ready for the BI & Big Data labs.")
        print("  Next step:")
        print("    1. Open this folder in VS Code.")
        print("    2. Lab 01 Primer: 03_labs_student_starters/lab_01_python_and_tooling_primer/lab_01_python_and_tooling_primer_workbook.ipynb")
        print("    3. Lab 02 Bronze: 03_labs_student_starters/lab_02_bronze_ingestion_and_profiling/lab_02_bronze_ingestion_and_exploration.ipynb")
        print("    4. Select the '.venv' kernel in the top-right corner of each notebook.")
        print("=" * 68 + "\n")
        return 0
    elif core_ok:
        print("  PARTIAL SUCCESS: Python, libraries, and raw Bronze datasets are ready,")
        print("  but VS Code setup is incomplete (your laptop is NOT 100% ready yet).")
        print("\n  Missing step(s):")
        for idx, step_msg in enumerate(missing_vscode_steps, start=1):
            print(f"    {idx}. {step_msg}")
        print(f"\n  Tip: You can also start JupyterLab immediately via: {sys.executable} -m jupyterlab")
        print("=" * 68 + "\n")
        return 0
    else:
        print("  WARNING: Some core checks failed. Please review the messages above")
        print("  or re-run setup_windows.bat (Windows) / ./setup_macos.sh (macOS) / ./setup_linux.sh (Linux).")
        if missing_vscode_steps:
            print("\n  Missing VS Code step(s):")
            for idx, step_msg in enumerate(missing_vscode_steps, start=1):
                print(f"    {idx}. {step_msg}")
        print("=" * 68 + "\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
