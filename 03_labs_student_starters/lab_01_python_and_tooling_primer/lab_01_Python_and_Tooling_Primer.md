**Course Reference:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Target Audience:** 4th Year B.Sc. Students, Management and Production Engineering (IFE, Lodz University of Technology)  
**Laboratory Session:** Laboratory #1 (Hands-on Foundations)  
**Instructors:** Tomasz Kołodziejczyk

---

# Python & Modern Tooling Ecosystem: A Practical Primer for Production Engineers

Welcome to the practical laboratory component of **Business Intelligence and Big Data Analysis**. If this is your very first time programming in Python or working outside of traditional spreadsheet software like Microsoft Excel, do not panic. This course does not expect you to be a computer science major or a software developer. Instead, you will approach Python the way an industrial engineer approaches a **precision CNC machine or a laser measurement gauge**: as a powerful, dependable tool designed to solve concrete operational problems, eliminate repetitive manual toil, and process data at a scale that breaks traditional office tools.

This primer walks you through the core concepts of Python syntax, explains why the global engineering and data analytics industry has standardized around it, and introduces the professional tooling ecosystem you will use throughout the semester: **Visual Studio Code**, **Python Virtual Environments (venv)**, and **Jupyter Notebooks**.

---

## 1. Why Python for Production & Industrial Engineers?

In traditional manufacturing and logistics environments, engineers often reach for Microsoft Excel to perform calculations, track scrap parts, and generate charts. While Excel is excellent for quick, one-off tabular checks, it fails catastrophically when an enterprise scales up:

* **Row Limits:** Excel cannot open a file with more than **1,048,576 rows**. A single smart energy meter recording readings every second hits that limit in less than two weeks.
* **Auditability & Reproducibility:** When someone accidentally drags a formula down a column and overwrites cell `C42` with a hardcoded number, the error is invisible until a board report fails. In code, every transformation step is explicit, version-controlled, and testable.
* **Multi-Source Automation:** Python serves as the universal "digital glue" of modern Industry 4.0. With Python, you can write a script that connects to an industrial database via SQL, pulls an external tariff schedule via a JSON API, standardizes timestamps, filters corrupted sensor noise, and pushes clean metrics into a Business Intelligence dashboard without any human intervention.

### Core Characteristics of the Language

* **High-Level & Human-Readable:** Python syntax was deliberately designed to mimic plain English. It removes visual noise such as mandatory semicolons at the end of lines or complex memory pointers.
* **Interpreted (No Compilation Step):** Unlike languages like C++ or Java, Python code does not need to be compiled into machine binaries before running. You can execute code line-by-line, inspect intermediate variables in memory, and debug data interactively.
* **Dynamically Typed:** You do not need to explicitly declare whether a variable is an integer, a floating-point number, or text when creating it. Python deduces the data type automatically at runtime.
* **Rich Open-Source Ecosystem:** Python's dominance is driven by its specialized third-party libraries: `pandas` for data manipulation, `numpy` for numerical computing, `duckdb` for lightning-fast analytical SQL queries, and `plotly` for interactive visualizations.

---

## 2. Essential Python Syntax & Mental Models

### 2.1. The Golden Rule: Significant Whitespace (Indentation)

In many programming languages, code blocks are enclosed in curly braces `{ ... }`. In Python, **indentation alone defines the scope and hierarchy of code blocks**. The universal industry convention is to use **4 spaces** per indentation level (never mix tabs and spaces):

```python
# Example: Indentation defining control flow
machine_status = "RUNNING"
measured_temperature = 318.5  # in Kelvin

if measured_temperature > 315.0:
    print("Warning: Thermal threshold exceeded!")
    if machine_status == "RUNNING":
        print("Action required: Engage auxiliary coolant pump immediately.")
else:
    print("Normal operating parameters.")
```

### 2.2. Primitive Data Types

| Type | Name | Examples | Industrial Context |
| :--- | :--- | :--- | :--- |
| `int` | Integer | `42`, `-10`, `0` | Discrete counts: parts produced, scrap counts, shift numbers. |
| `float` | Floating-point | `3.1415`, `-999.0`, `45.8` | Continuous physical measurements: torque (Nm), temperatures (K), power (kWh). |
| `str` | String (Text) | `"PRESS_01"`, `'Line_A'` | Identifiers, failure mode codes, customer names, raw dates before parsing. |
| `bool` | Boolean | `True`, `False` | Flags: `is_breakdown`, `quality_approved`, `is_peak_hour`. |
| `NoneType` | None (Null) | `None` | Represents missing data, sensor drop-outs, or unrecorded fields. |

### 2.3. Core Data Structures (Collections)

When handling manufacturing data, individual values are grouped into collections. The two most important structures are **Lists** and **Dictionaries**:

```python
# 1. LISTS: Ordered, mutable collections of items (indexed starting at 0)
stamping_presses = ["PRESS_01", "PRESS_02", "PRESS_03"]
stamping_presses.append("PRESS_04")
print("First machine in line:", stamping_presses[0])  # Output: PRESS_01

# 2. DICTIONARIES: Key-value mappings (the mental model behind JSON)
machine_telemetry = {
    "machine_id": "PRESS_01",
    "nominal_cycle_sec": 12.0,
    "operating_cost_eur": 180.0,
    "is_operational": True,
}
print(f"Machine operating cost: {machine_telemetry['operating_cost_eur']} EUR/h")
```

### 2.4. Functions: Reusable Engineering Logic

Functions encapsulate repetitive calculations so you can apply the same logic to thousands of records consistently:

```python
def calculate_scrap_rate(produced_units: int, scrap_units: int) -> float:
    """Calculates the percentage of defective production units."""
    if produced_units <= 0:
        return 0.0
    return round((scrap_units / produced_units) * 100, 2)

batch_scrap = calculate_scrap_rate(produced_units=1500, scrap_units=45)
print(f"Batch Scrap Rate: {batch_scrap}%")  # Output: 3.0%
```

---

## 3. The Professional Development Environment: Visual Studio Code

**Visual Studio Code (VS Code)** is the industry-standard source code editor developed by Microsoft. It is free, open-source, and runs identically across Windows, macOS, and Linux. Unlike heavyweight monolithic IDEs, VS Code is lightweight and modular: it adapts to your project through **Extensions**.

### Key Interface Components in VS Code

1. **Activity Bar (Far Left):** Provides fast navigation between the File Explorer (folder tree), Global Search, Source Control (Git), Run/Debug, and Extensions Marketplace.
2. **Sidebar (Explorer):** Shows all files, data packs, scripts, and notebooks inside your current project workspace.
3. **Editor Area (Center):** Where you write Python scripts (`.py`) or interact with Jupyter Notebooks (`.ipynb`).
4. **Integrated Terminal (Bottom, ``Ctrl + ` `` or ``Cmd + ` ``):** A built-in command prompt (PowerShell, Bash, or Zsh) used to run terminal commands, manage virtual environments, and install software packages without switching windows.
5. **Command Palette (`Ctrl + Shift + P` or `Cmd + Shift + P`):** The universal control hub of VS Code. If you ever forget where a setting or command is, press this shortcut and start typing.

### Essential Extensions for This Course

* **Python (by Microsoft):** Adds code completion (IntelliSense), syntax highlighting, linting, and debugger integration.
* **Jupyter (by Microsoft):** Allows you to create, view, run, and edit Jupyter Notebooks directly inside VS Code without needing an external browser.
* **DuckDB SQL Tools (or SQLTools):** Enables direct querying, inspection, and schema viewing of your analytical `.duckdb` database files.
* **DBML (Database Markup Language):** Provides syntax highlighting for `.dbml` dimensional modeling files when designing your Kimball Star Schemas.

---

## 4. Dependency Isolation: Python Virtual Environments (`venv`)

### 4.1. Why Do We Need Virtual Environments?

When you install Python on a computer, it comes with a central, global package directory called `site-packages`. If you simply type `pip install pandas` in your global terminal, the package is installed system-wide. This leads to a well-known industry trap called **"Dependency Hell"**:

* Suppose another course or university project requires an older version of a library (e.g., `pandas==1.3.0`), while our BI course requires modern features from `pandas>=2.2.0`. Installing one overwrites the other, breaking your previous work.
* On university lab computers, administrative policies frequently freeze the system drive (`C:`) or lock global Python directories, preventing standard users from modifying system-wide packages.

A **Virtual Environment** is an isolated, self-contained directory tree that contains a specific Python interpreter and its own private set of installed libraries. Each project gets its own isolated sandbox.

### 4.2. Step-by-Step Terminal Workflow

*(Note: Running `setup_windows.bat`, `./setup_macos.sh`, or `./setup_linux.sh` from the repository root performs all steps below automatically!)*

```bash
# STEP 1: Open the integrated terminal in VS Code and verify Python version
python --version   # Must report Python 3.11, 3.12, or 3.13 (or use python3 on macOS/Linux)

# STEP 2: Create a virtual environment named '.venv' in your project directory
python -m venv .venv

# STEP 3: Activate the virtual environment
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1
# (Note: If PowerShell blocks script execution, run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass)

# On macOS / Linux:
source .venv/bin/activate

# STEP 4: Confirm activation — your terminal prompt now displays '(.venv)' at the left!

# STEP 5: Upgrade pip and install project requirements using pre-built binary wheels
python -m pip install --upgrade pip
python -m pip install --prefer-binary -r requirements.txt ipykernel

# STEP 6: Deactivating (when finished with your work session)
deactivate
```

---

## 5. Interactive Computing: Jupyter Notebooks (`.ipynb`)

### 5.1. What is a Notebook?

In traditional software engineering, developers write code in static scripts (`.py`) and run the entire program from start to finish. In data analytics and business intelligence, reloading a large telemetry file just to tweak a chart wastes time. A **Jupyter Notebook** implements **Literate Programming**: an interactive document combining executable code blocks, Markdown narrative, tables, and visualizations in one place.

### 5.2. Anatomy of a Notebook: Code vs. Markdown

* **Code Cells:** Contain executable Python code. When you run a code cell, the Python engine (the **Kernel**) processes the code, updates the memory state, and displays text output, tables, or charts directly beneath the cell.
* **Markdown Cells:** Contain formatted explanatory text, equations, and documentation (e.g., `# Heading 1`, `**bold text**`, or LaTeX formulas such as $OEE = A \times P \times Q$). In this course, documenting engineering assumptions in Markdown is as important as writing Python code.

### 5.3. The Execution Flow Trap (Out-of-Order Execution)

Because notebooks allow running cells individually in any order, beginners frequently fall into the **Out-of-Order Execution Trap**:

1. You define `target_oee = 0.85` in Cell `[1]`.
2. You change it to `target_oee = 0.90` in Cell `[4]` and run Cell `[4]`.
3. You jump back up and re-run Cell `[2]`, expecting `0.85`, but it reads `0.90` from memory!

**The Golden Notebook Rule:** Before submitting any lab deliverable or presenting your findings, always click **"Restart Kernel and Run All Cells"** (double-arrow icon in the top toolbar). Your notebook must execute cleanly from top to bottom on a fresh slate.

### 5.4. Essential Keyboard Shortcuts

| Shortcut | Action | Usage Note |
| :--- | :--- | :--- |
| **`Shift + Enter`** | Execute Current Cell | Runs the active cell and advances cursor to the next cell. |
| **`Ctrl + Enter`** (`Cmd + Enter`) | Execute In-Place | Runs the active cell and keeps the selection cursor on it. |
| **`Escape`** | Command Mode | Exits cell editing mode so you can navigate cells with arrow keys. |
| **`A`** *(Command Mode)* | Insert Cell Above | Inserts a blank cell directly above the current one. |
| **`B`** *(Command Mode)* | Insert Cell Below | Inserts a blank cell directly below the current one. |
| **`D + D`** *(press D twice)* | Delete Active Cell | Removes the active cell from the notebook. |
| **`M` / `Y`** | Switch Cell Type | Press `M` to convert to Markdown; `Y` to convert back to Python Code. |

---

## 6. Practical Checklist for Laboratory #1 (First 20 Minutes)

1. **Launch VS Code:** Open Visual Studio Code from the desktop or applications menu.
2. **Open Project Folder:** Select **File ➔ Open Folder...** and open your cloned repository folder (avoid working directly inside a `.zip` file or cloud-synced `Documents` folders).
3. **Open Integrated Terminal:** Press ``Ctrl + ` `` (or `Terminal ➔ New Terminal`).
4. **Verify `.venv` & Dependencies:** Run `python verify_environment.py` (or create `.venv` and install `-r requirements.txt` if manual).
5. **Select Jupyter Kernel:** Open `lab_01_python_and_tooling_primer_workbook.ipynb`, click **"Select Kernel"** (top-right) ➔ **"Python Environments..."** ➔ select **`.venv`**.
6. **Complete Primer Warm-Up:** Work through every exercise cell in `lab_01_python_and_tooling_primer_workbook.ipynb`, then verify **Restart Kernel and Run All Cells** succeeds cleanly. Next session (**Lab 02**), move to `../lab_02_bronze_ingestion_and_profiling/lab_02_bronze_ingestion_and_exploration.ipynb`!
