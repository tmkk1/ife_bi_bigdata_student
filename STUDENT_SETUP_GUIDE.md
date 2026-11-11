# 💻 Student Laptop Setup Guide (Windows & macOS)

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Faculty:** International Faculty of Engineering (IFE), Lodz University of Technology  
**Instructor:** Tomasz Kołodziejczyk

---

## 🚀 Option A: Automated 1-Step Setup (Recommended — Takes ~3 Minutes)

Instead of manually downloading files from MS Teams and configuring paths by hand, run our automated setup script. It will automatically:
1. Check your operating system (Windows 10/11 or macOS Intel/Apple Silicon).
2. Install **Python 3.12** and **Visual Studio Code** if you don't already have them.
3. Download the official **Student Course Repository** into a standardized folder on your computer.
4. Create an isolated **Virtual Environment (`.venv`)** and install all required libraries (`pandas`, `numpy`, `openpyxl`, `duckdb`, `pyarrow`, `plotly`, `jupyterlab`, `ipykernel`).
5. Register the `.venv` Jupyter Kernel, configure VS Code extensions, and verify that all raw **Bronze case study datasets** are in place.

---

### 🪟 For Windows 10 & Windows 11

#### Method 1: One-Line PowerShell Bootstrap (Fastest)
1. Press the **Windows Key**, type **`PowerShell`**, and click **Open** (no Administrator rights needed).
2. Copy and paste the following command into PowerShell and press **Enter**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/tmkk1/ife_bi_bigdata_student/main/setup_windows.ps1 | iex
```

#### Method 2: If You Downloaded / Cloned the Repository Already
1. Open the repository folder in File Explorer.
2. Double-click **`setup_windows.bat`**.
   *(If Windows SmartScreen asks "Windows protected your PC", click **More info** ➔ **Run anyway**).*

---

### 🍎 For macOS (Apple Silicon M1/M2/M3/M4 & Intel — With or Without Xcode)

> **Important Note for Mac Users:** You do **NOT** need to install the 15 GB Xcode app or wait 20 minutes for Xcode Command Line Tools! Our script automatically uses official universal binary packages and pre-built wheels if Xcode is not installed.

#### Method 1: One-Line Terminal Bootstrap (Fastest)
1. Press **`Cmd + Space`** to open Spotlight, type **`Terminal`**, and press **Enter**.
2. Copy and paste the following command into Terminal and press **Enter**:

```bash
curl -fsSL https://raw.githubusercontent.com/tmkk1/ife_bi_bigdata_student/main/setup_macos.sh | bash
```

*(Note: If your Mac does not have Python 3.10+ installed yet, the script will download the official Python 3.12 installer and ask for your Mac login password in the Terminal to install it).*

#### Method 2: If You Downloaded / Cloned the Repository Already
1. Open **Terminal** in the repository folder and run:

```bash
chmod +x setup_macos.sh
./setup_macos.sh
```

---

## 🛠️ Option B: Step-by-Step Manual Setup (Fallback)

If you prefer to set up your environment manually or if university Wi-Fi blocks automated installers, follow these exact steps:

### Step 1: Install Required Software
1. **Python (3.10, 3.11, or 3.12):**
   * **Windows:** Download [Python 3.12 (64-bit Windows Installer)](https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe).  
     ⚠️ **CRITICAL ON WINDOWS:** On the very first installer screen, check the box **"Add python.exe to PATH"** before clicking *Install Now*!
   * **macOS:** Download [Python 3.12 (macOS 11+ Universal2 Installer)](https://www.python.org/ftp/python/3.12.7/python-3.12.7-macos11.pkg) and double-click to install.
2. **Visual Studio Code:**
   * Download and install from [https://code.visualstudio.com/](https://code.visualstudio.com/).

---

### Step 2: Get the Course Files (Standardized Folder Structure)
All lab notebooks automatically locate raw datasets using the repository folder tree. **Never open a single `.ipynb` file directly from your `Downloads` folder or inside a `.zip` file!**

* **If you have Git installed:** Open your terminal (`PowerShell` on Windows or `Terminal` on macOS) and run:
  ```bash
  cd ~/Documents
  git clone https://github.com/tmkk1/ife_bi_bigdata_student.git
  cd ife_bi_bigdata_student
  ```
* **If you do NOT have Git installed:**
  1. Go to [`https://github.com/tmkk1/ife_bi_bigdata_student`](https://github.com/tmkk1/ife_bi_bigdata_student).
  2. Click the green **`<> Code`** button ➔ **`Download ZIP`**.
  3. Extract (Unzip) the entire folder into your `Documents` folder so you have `Documents/ife_bi_bigdata_student`.

---

### Step 3: Open the Folder in VS Code & Install Extensions
1. Launch **Visual Studio Code**.
2. Click **File ➔ Open Folder...** and select the **`ife_bi_bigdata_student`** root folder.
3. Click the **Extensions** icon on the left sidebar (`Ctrl+Shift+X` on Windows / `Cmd+Shift+X` on macOS) and install:
   * **Python** (by Microsoft)
   * **Jupyter** (by Microsoft)

---

### Step 4: Create & Activate Your Virtual Environment (`.venv`)
Open the Integrated Terminal inside VS Code (`Terminal ➔ New Terminal` or press `` Ctrl+` ``):

#### On Windows (PowerShell):
```powershell
# 1. Allow activating virtual environments in PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Create virtual environment named .venv
python -m venv .venv

# 3. Activate .venv
.\.venv\Scripts\Activate.ps1

# 4. Upgrade pip and install course libraries + Jupyter kernel
python -m pip install --upgrade pip
pip install -r requirements.txt ipykernel

# 5. Verify setup & raw Bronze datasets
python verify_environment.py
```

#### On macOS / Linux (Terminal):
```bash
# 1. Create virtual environment named .venv
python3 -m venv .venv

# 2. Activate .venv
source .venv/bin/activate

# 3. Upgrade pip and install course libraries + Jupyter kernel
python -m pip install --upgrade pip
pip install --prefer-binary -r requirements.txt ipykernel

# 4. Verify setup & raw Bronze datasets
python verify_environment.py
```

---

## 📓 Step 5: Launching Lab 01 & Lab 02 in VS Code

1. In the VS Code Explorer sidebar (left), start with **Lab 01** (`03_labs_student_starters/lab_01_python_and_tooling_primer/`):
   * **`lab_01_Python_and_Tooling_Primer.md`** (or `_fr.md`) — Reference guide
   * **`lab_01_python_and_tooling_primer_workbook.ipynb`** (or `_fr.ipynb`) — 3-hour Python & Tooling warm-up
2. Next session (**Lab 02 — Bronze Ingestion & Profiling**), open `03_labs_student_starters/lab_02_bronze_ingestion_and_profiling/`:
   * **`lab_02_bronze_ingestion_and_exploration.ipynb`** (or `_fr.ipynb`) — Multi-format (`CSV + JSON + XLSX`) ingestion using the datasets staged inside `lab_02_bronze_ingestion_and_profiling/data/`.
3. **Select the Kernel (Top-Right Corner of Every Notebook):**
   * Click **"Select Kernel"** (top-right) ➔ **"Python Environments..."** ➔ select **`.venv (Python 3.1x)`**.
4. In Lab 02, press **`Shift + Enter`** on the first code cell to verify `BRONZE_RAW.exists() == True`!

---

## ❓ Troubleshooting Common Laptop Issues

| Issue / Error Message | Cause | Quick Fix |
| :--- | :--- | :--- |
| **Windows:** `'python' is not recognized` or typing `python` opens the Microsoft Store | Python wasn't added to PATH, or Windows App Execution Alias intercepts `python`. | Run `py -3 -m venv .venv` instead of `python -m venv .venv`, or re-run `setup_windows.bat`. |
| **Windows:** `Activate.ps1 cannot be loaded because running scripts is disabled` | Windows default PowerShell ExecutionPolicy blocks scripts. | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` in the terminal, then run `.\.venv\Scripts\Activate.ps1`. |
| **macOS:** Popup asking to install *"command line developer tools"* when typing `python3` or `git` | macOS `/usr/bin/python3` is a stub when Xcode CLT is not installed. | Cancel the slow popup and run `./setup_macos.sh` — it installs official Python 3.12 from `python.org` (`/Library/Frameworks/...`) in 1 minute without needing Xcode! |
| **macOS:** `SSL: CERTIFICATE_VERIFY_FAILED` when running `pip install` | Official `python.org` macOS installer needs its root certificates initialized. | Run: `sh "/Applications/Python 3.12/Install Certificates.command"` in Terminal. |
| **VS Code:** Running a cell says *"Running cells with '.venv' requires the ipykernel package"* | `ipykernel` is missing or the wrong kernel is selected. | Activate `.venv` in terminal and run `pip install ipykernel`, then click the kernel name in the top-right of the notebook and pick `.venv`. |
| **Notebook:** `Raw Bronze Directory exists: False` or `FileNotFoundError` | You opened a single downloaded `.ipynb` file outside the repo structure, or raw data wasn't generated. | Open the entire `ife_bi_bigdata_student` folder in VS Code (`File ➔ Open Folder...`) and run `python verify_environment.py`. |

