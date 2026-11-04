<#
.SYNOPSIS
    Automated Student Environment Setup Script for Windows 10 & Windows 11
    Course: Business Intelligence and Big Data Analysis (01 31 0367 00) - IFE, TUL
.DESCRIPTION
    1. Evaluates local Windows environment (OS build, PowerShell ExecutionPolicy, Git, Python, VS Code).
    2. Installs Python 3.12, Git, and VS Code automatically if missing or outdated.
    3. Clones or updates the student course repository so everyone has the exact same folder structure.
    4. Creates a local virtual environment (.venv) and installs all required Python packages + Jupyter kernel.
    5. Configures VS Code settings & extensions (Python + Jupyter) and verifies raw Bronze datasets.
#>

param(
    [string]$RepoUrl = "https://github.com/tmkk1/ife_bi_bigdata_student.git",
    [string]$TargetDirName = "ife_bi_bigdata_student"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host "`n====================================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
    Write-Host "  [OK]   $Message" -ForegroundColor Green
}

function Write-Info([string]$Message) {
    Write-Host "  [INFO] $Message" -ForegroundColor Yellow
}

function Write-Err([string]$Message) {
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Refresh-SessionPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $userPath    = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    
    $combined = @($userPath, $machinePath) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $env:Path = $combined -join ";"
}

Write-Step "STEP 1: Evaluating Local Windows Environment"

$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "  OS Caption       : $($osInfo.Caption)"
Write-Host "  OS Version/Build : $($osInfo.Version) (Build $($osInfo.BuildNumber))"
Write-Host "  Architecture     : $($osInfo.OSArchitecture)"

# Allow activating .venv in VS Code PowerShell terminals without PSSecurityException
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    Write-Ok "PowerShell ExecutionPolicy set to RemoteSigned for CurrentUser."
} catch {
    Write-Info "Could not persist ExecutionPolicy (may be managed by group policy); continuing in Bypass mode."
}

$hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
if ($hasWinget) {
    Write-Ok "Windows Package Manager (winget) is available."
} else {
    Write-Info "winget not found; direct official HTTPS installers will be used as fallback."
}

# ---------------------------------------------------------------------------
# STEP 2: Check / Install Python (3.10 - 3.12)
# ---------------------------------------------------------------------------
Write-Step "STEP 2: Checking Python Installation (Requires Python 3.10+)"

function Find-ValidPython {
    Refresh-SessionPath

    # 1. Check py launcher for 3.12, 3.11, 3.13, 3.10
    if (Get-Command py -ErrorAction SilentlyContinue) {
        foreach ($ver in @("-3.12", "-3.11", "-3.13", "-3.10", "-3")) {
            try {
                $out = & py $ver -c "import sys; print(sys.executable if sys.version_info >= (3,10) else '')" 2>$null
                if ($LASTEXITCODE -eq 0 -and $out -and (Test-Path $out.Trim())) {
                    return $out.Trim()
                }
            } catch {}
        }
    }

    # 2. Check python command (ignoring Windows Store stub in WindowsApps)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        try {
            $out = & python -c "import sys; print(sys.executable if sys.version_info >= (3,10) else '')" 2>$null
            if ($LASTEXITCODE -eq 0 -and $out -and ($out -notmatch "WindowsApps") -and (Test-Path $out.Trim())) {
                return $out.Trim()
            }
        } catch {}
    }

    # 3. Check standard install directories
    $candidates = @(
        "$env:LocalAppData\Programs\Python\Python312\python.exe",
        "$env:LocalAppData\Programs\Python\Python311\python.exe",
        "$env:LocalAppData\Programs\Python\Python313\python.exe",
        "$env:LocalAppData\Programs\Python\Python310\python.exe",
        "C:\Program Files\Python312\python.exe",
        "C:\Program Files\Python311\python.exe",
        "C:\Program Files\Python313\python.exe",
        "C:\Program Files\Python310\python.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            return $c
        }
    }
    return $null
}

$pythonExe = Find-ValidPython

if (-not $pythonExe) {
    Write-Info "Compatible Python (3.10+) not found. Installing Python 3.12..."
    if ($hasWinget) {
        try {
            winget install -e --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Info "winget install returned an error, falling back to direct python.org installer..."
        }
    }
    $pythonExe = Find-ValidPython
    if (-not $pythonExe) {
        $pyInstallerUrl = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe"
        $pyInstallerPath = Join-Path $env:TEMP "python-3.12.7-amd64.exe"
        Write-Info "Downloading Python 3.12.7 installer from python.org..."
        Invoke-WebRequest -Uri $pyInstallerUrl -OutFile $pyInstallerPath -UseBasicParsing
        Write-Info "Running silent Python 3.12 installation (please wait 1-2 minutes)..."
        Start-Process -FilePath $pyInstallerPath -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_launcher=1" -Wait
        $pythonExe = Find-ValidPython
    }
}

if (-not $pythonExe) {
    Write-Err "Python 3.10+ could not be installed automatically. Please install Python 3.12 from https://www.python.org/downloads/ (check 'Add python.exe to PATH') and re-run."
    exit 1
}

$pyVer = & $pythonExe --version
Write-Ok "Using $pyVer at: $pythonExe"

# ---------------------------------------------------------------------------
# STEP 3: Check / Install Visual Studio Code
# ---------------------------------------------------------------------------
Write-Step "STEP 3: Checking Visual Studio Code"

function Find-VSCode {
    Refresh-SessionPath
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $paths = @(
        "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd",
        "C:\Program Files\Microsoft VS Code\bin\code.cmd"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$codeCmd = Find-VSCode
if (-not $codeCmd) {
    Write-Info "VS Code not found. Installing Visual Studio Code..."
    if ($hasWinget) {
        try {
            winget install -e --id Microsoft.VisualStudioCode --scope user --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Info "winget VS Code install failed, downloading direct installer..."
        }
    }
    $codeCmd = Find-VSCode
    if (-not $codeCmd) {
        $vscodeUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
        $vscodeInstaller = Join-Path $env:TEMP "VSCodeUserSetup-x64.exe"
        Write-Info "Downloading VS Code User Installer..."
        Invoke-WebRequest -Uri $vscodeUrl -OutFile $vscodeInstaller -UseBasicParsing
        Write-Info "Installing VS Code silently..."
        Start-Process -FilePath $vscodeInstaller -ArgumentList "/VERYSILENT /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait
        $codeCmd = Find-VSCode
    }
}

if ($codeCmd) {
    Write-Ok "VS Code found at: $codeCmd"
    Write-Info "Installing required VS Code extensions (Python & Jupyter)..."
    try {
        & $codeCmd --install-extension ms-python.python --force
        & $codeCmd --install-extension ms-toolsai.jupyter --force
        Write-Ok "VS Code Python & Jupyter extensions installed."
    } catch {
        Write-Info "Could not install extensions via CLI; you can install 'Python' and 'Jupyter' from the Extensions tab in VS Code."
    }
} else {
    Write-Info "VS Code was not detected. You can download it from https://code.visualstudio.com/"
}

# ---------------------------------------------------------------------------
# STEP 4: Check Git & Sync Course Repository Structure
# ---------------------------------------------------------------------------
Write-Step "STEP 4: Setting Up Course Directory Structure & Files"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ((Test-Path (Join-Path $scriptDir "requirements.txt")) -and (Test-Path (Join-Path $scriptDir "03_labs_student_starters"))) {
    $repoRoot = $scriptDir
    Write-Ok "Already running inside course repository: $repoRoot"
    if ((Test-Path (Join-Path $repoRoot ".git")) -and (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Info "Pulling latest updates from Git remote..."
        Push-Location $repoRoot
        try {
            git pull --ff-only
        } catch {
            Write-Info "Could not fast-forward pull (you may have local changes). Keeping local files."
        }
        Pop-Location
    }
} else {
    # Running as standalone bootstrapper
    $parentDir = [Environment]::GetFolderPath("MyDocuments")
    if (-not $parentDir -or -not (Test-Path $parentDir)) {
        $parentDir = $HOME
    }
    $repoRoot = Join-Path $parentDir $TargetDirName

    # Ensure Git is available or fall back to ZIP download
    $hasGit = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    if (-not $hasGit -and $hasWinget) {
        Write-Info "Git not found. Installing Git via winget..."
        try {
            winget install -e --id Git.Git --scope user --accept-package-agreements --accept-source-agreements
            Refresh-SessionPath
            $hasGit = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
        } catch {}
    }

    if (Test-Path (Join-Path $repoRoot ".git")) {
        Write-Info "Repository already exists at $repoRoot. Pulling latest changes..."
        Push-Location $repoRoot
        try { git pull --ff-only } catch {}
        Pop-Location
    } elseif ($hasGit) {
        Write-Info "Cloning student repository from $RepoUrl into $repoRoot..."
        git clone $RepoUrl $repoRoot
    } else {
        Write-Info "Git not installed; downloading repository ZIP archive directly..."
        $zipUrl = $RepoUrl -replace "\.git$", "/archive/refs/heads/main.zip"
        $zipFile = Join-Path $env:TEMP "ife_bi_course.zip"
        $extractDir = Join-Path $env:TEMP "ife_bi_course_extract"
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
        $innerFolder = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
        if (-not (Test-Path $repoRoot)) { New-Item -ItemType Directory -Path $repoRoot | Out-Null }
        Copy-Item -Path "$($innerFolder.FullName)\*" -Destination $repoRoot -Recurse -Force
    }
    Write-Ok "Course files ready at: $repoRoot"
}

# ---------------------------------------------------------------------------
# STEP 5: Create Virtual Environment (.venv) & Install Dependencies
# ---------------------------------------------------------------------------
Write-Step "STEP 5: Creating Virtual Environment (.venv) & Installing Packages"

Push-Location $repoRoot
$venvDir = Join-Path $repoRoot ".venv"
$venvPython = Join-Path $venvDir "Scripts\python.exe"

if (-not (Test-Path $venvPython)) {
    Write-Info "Creating virtual environment in $venvDir..."
    & $pythonExe -m venv .venv
}

if (-not (Test-Path $venvPython)) {
    Write-Err "Failed to create .venv at $venvDir"
    Pop-Location
    exit 1
}
Write-Ok "Virtual environment created: $venvPython"

Write-Info "Upgrading pip and installing course requirements (pandas, duckdb, pyarrow, plotly, jupyter, ipykernel)..."
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r requirements.txt ipykernel

Write-Info "Registering .venv as a Jupyter Notebook Kernel..."
& $venvPython -m ipykernel install --user --name "ife-bi-venv" --display-name "Python (.venv - BI & Big Data)"
Write-Ok "Jupyter Kernel registered."

# Configure VS Code workspace settings so .venv is selected automatically
$vscodeDir = Join-Path $repoRoot ".vscode"
if (-not (Test-Path $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir | Out-Null
}
$settingsJson = @'
{
    "python.defaultInterpreterPath": "${workspaceFolder}\\.venv\\Scripts\\python.exe",
    "python.terminal.activateEnvironment": true,
    "jupyter.jupyterServerType": "local"
}
'@
Set-Content -Path (Join-Path $vscodeDir "settings.json") -Value $settingsJson -Encoding UTF8
Write-Ok "Configured .vscode/settings.json to auto-select .venv interpreter."

# ---------------------------------------------------------------------------
# STEP 6: Verify Environment & Raw Bronze Datasets
# ---------------------------------------------------------------------------
Write-Step "STEP 6: Running Environment & Data Verification"

if (Test-Path (Join-Path $repoRoot "verify_environment.py")) {
    & $venvPython verify_environment.py
}

Pop-Location

if ($codeCmd) {
    Write-Info "Launching Visual Studio Code in $repoRoot..."
    Start-Process -FilePath $codeCmd -ArgumentList "`"$repoRoot`""
}

Write-Host "`nAll done! You can close this window and work inside VS Code." -ForegroundColor Green
