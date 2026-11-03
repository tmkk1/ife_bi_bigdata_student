#!/usr/bin/env python3
"""Environment & Data Verification Script for Students.
Course: Business Intelligence and Big Data Analysis (01 31 0367 00)
"""
from __future__ import annotations

import os
import platform
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

CASE_RAW_FILES = {
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

    if (v.major, v.minor) < (3, 10):
        print("  [FAIL] Python 3.10+ is required (3.11 or 3.12 recommended).")
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
    lab01_data = repo_root / "03_labs_student_starters" / "lab_01_bronze_ingestion" / "data"
    ref_dir = repo_root / "05_case_studies_reference_solutions"

    all_present = True
    for case_name, files in CASE_RAW_FILES.items():
        # Check student repo path first, then reference path
        candidate_dirs = [
            lab01_data / case_name,
            lab01_data / case_name / "bronze",
            ref_dir / case_name / "data" / "bronze",
        ]
        active_dir = None
        for d in candidate_dirs:
            if d.exists() and all((d / f).exists() for f in files):
                active_dir = d
                break

        if active_dir is None:
            # Check if partial files exist or need generation in instructor repo
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
        else:
            print(f"  [FAIL] {case_name:<30} ({present_count}/{len(files)} raw files found)")
            all_present = False

    return all_present


def main() -> int:
    repo_root = Path(__file__).resolve().parent

    print_header("1. SYSTEM & PYTHON ENVIRONMENT CHECK")
    py_ok = check_python_version()

    print_header("2. PYTHON LIBRARIES CHECK")
    pkg_ok = check_packages()

    print_header("3. COURSE STRUCTURE & RAW BRONZE DATA CHECK")
    data_ok = check_and_generate_data(repo_root)

    print_header("SUMMARY")
    if py_ok and pkg_ok and data_ok:
        print("  SUCCESS! Your laptop is 100% ready for the BI & Big Data labs.")
        print("  Next step:")
        print("    1. Open this folder in VS Code.")
        print("    2. Open: 03_labs_student_starters/lab_01_bronze_ingestion/lab_01_bronze_ingestion_and_exploration.ipynb")
        print("    3. Select the '.venv' kernel in the top-right corner of the notebook.")
        print("=" * 68 + "\n")
        return 0
    else:
        print("  WARNING: Some checks failed. Please review the messages above")
        print("  or re-run setup_windows.bat (Windows) / ./setup_macos.sh (macOS).")
        print("=" * 68 + "\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())

