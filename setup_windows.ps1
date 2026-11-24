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
    [string]$TargetDirName = ""
)

if (-not $TargetDirName) {
    $TargetDirName = "ife_bi_bigdata_student_$(Get-Date -Format 'yyyy-MM-dd')"
}

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
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$userPath;$machinePath"
}

Write-Step "STEP 1: Evaluating Local Windows Environment"

$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "  OS Caption       : $($osInfo.Caption)"
Write-Host "  OS Version/Build : $($osInfo.Version) (Build $($osInfo.BuildNumber))"
Write-Host "  Architecture     : $($osInfo.OSArchitecture)"

# Allow activating .venv in VS Code PowerShell terminals without PSSecurityException
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    Write-Ok "PowerShell ExecutionPolicy set to RemoteSigned for CurrentUser."
} catch {
    # When launched with '-Scope Process Bypass', PowerShell persists CurrentUser
    # before raising a scope-override warning. Check the actual policies instead of guessing.
    $cuPolicy = [string](Get-ExecutionPolicy -Scope CurrentUser)
    $mpPolicy = [string](Get-ExecutionPolicy -Scope MachinePolicy)
    $upPolicy = [string](Get-ExecutionPolicy -Scope UserPolicy)
    if ($mpPolicy -in @("Restricted", "AllSigned") -or $upPolicy -in @("Restricted", "AllSigned")) {
        Write-Info "PowerShell ExecutionPolicy is restricted by Group Policy (MachinePolicy=$mpPolicy, UserPolicy=$upPolicy)."
        Write-Info "If .venv does not auto-activate in VS Code terminal, run commands directly with: .\.venv\Scripts\python.exe"
    } elseif ($cuPolicy -in @("RemoteSigned", "Unrestricted", "Bypass")) {
        Write-Ok "PowerShell ExecutionPolicy is '$cuPolicy' for CurrentUser."
    } else {
        Write-Info "Could not persist ExecutionPolicy (CurrentUser=$cuPolicy); continuing in Bypass mode."
    }
}

$hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
if ($hasWinget) {
    Write-Ok "Windows Package Manager (winget) is available."
} else {
    Write-Info "winget not found; direct official HTTPS installers will be used as fallback."
}

# ---------------------------------------------------------------------------
# STEP 2: Check / Install Python (Requires 64-bit Python 3.11-3.13 with venv)
# ---------------------------------------------------------------------------
Write-Step "STEP 2: Checking Python Installation (Requires 64-bit Python 3.11-3.13)"

$pyCheckCode = "import sys, venv, ensurepip; ok = (3,11) <= sys.version_info < (3,14) and sys.maxsize > 2**32; print(sys.executable if ok else '')"

function Test-PythonCandidate([string]$ExePath) {
    if (-not $ExePath -or ($ExePath -match "WindowsApps") -or (-not (Test-Path $ExePath))) {
        return $null
    }
    try {
        $out = & $ExePath -c $pyCheckCode 2>$null
        $outLine = ($out | Where-Object { $_ } | Select-Object -Last 1)
        if ($LASTEXITCODE -eq 0 -and $outLine) {
            $resolved = $outLine.ToString().Trim()
            if ($resolved -and ($resolved -notmatch "WindowsApps") -and (Test-Path $resolved)) {
                return $resolved
            }
        }
    } catch {}
    return $null
}

function Find-ValidPython {
    Refresh-SessionPath

    # 1. Check py launcher for 3.12, 3.11, 3.13, 3 (64-bit, < 3.14 for binary wheels, excluding Store stub)
    if (Get-Command py -ErrorAction SilentlyContinue) {
        foreach ($ver in @("-3.12", "-3.11", "-3.13", "-3")) {
            try {
                $out = & py $ver -c $pyCheckCode 2>$null
                $outLine = ($out | Where-Object { $_ } | Select-Object -Last 1)
                if ($LASTEXITCODE -eq 0 -and $outLine) {
                    $resolved = $outLine.ToString().Trim()
                    if ($resolved -and ($resolved -notmatch "WindowsApps") -and (Test-Path $resolved)) {
                        return $resolved
                    }
                }
            } catch {}
        }
    }

    # 2. Check python command (ignoring Windows Store stub in WindowsApps)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        try {
            $out = & python -c $pyCheckCode 2>$null
            $outLine = ($out | Where-Object { $_ } | Select-Object -Last 1)
            if ($LASTEXITCODE -eq 0 -and $outLine) {
                $resolved = $outLine.ToString().Trim()
                if ($resolved -and ($resolved -notmatch "WindowsApps") -and (Test-Path $resolved)) {
                    return $resolved
                }
            }
        } catch {}
    }

    # 3. Check standard install directories (3.11-3.13 only, validated for 64-bit + venv + ensurepip)
    $candidates = @(
        "$env:LocalAppData\Programs\Python\Python312\python.exe",
        "$env:LocalAppData\Programs\Python\Python311\python.exe",
        "$env:LocalAppData\Programs\Python\Python313\python.exe",
        "C:\Program Files\Python312\python.exe",
        "C:\Program Files\Python311\python.exe",
        "C:\Program Files\Python313\python.exe"
    )
    foreach ($c in $candidates) {
        $valid = Test-PythonCandidate $c
        if ($valid) {
            return $valid
        }
    }
    return $null
}

$pythonInstalledThisRun = $false
$pythonExe = Find-ValidPython

if (-not $pythonExe) {
    Write-Info "Compatible 64-bit Python (3.11-3.13 with venv) not found. Installing Python 3.12..."
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
    if ($pythonExe) {
        $pythonInstalledThisRun = $true
    }
}

if (-not $pythonExe) {
    Write-Err "Compatible 64-bit Python 3.11-3.13 could not be installed automatically. Please install Python 3.12 (64-bit) from https://www.python.org/downloads/ (check 'Add python.exe to PATH') and re-run."
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
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

$vscodeWasRunning = $null -ne (Get-Process -Name "Code" -ErrorAction SilentlyContinue)
$extensionsInstalledNow = @()
$missingExtensions = @()
$requiredExtensions = @("ms-python.python", "ms-toolsai.jupyter", "ms-toolsai.datawrangler")

if ($codeCmd) {
    Write-Ok "VS Code found at: $codeCmd"
    Write-Info "Checking required VS Code extensions (Python, Jupyter & Data Wrangler)..."
    try {
        $installedExts = @()
        try {
            $rawExts = & $codeCmd --list-extensions 2>$null
            if ($LASTEXITCODE -eq 0 -and $rawExts) {
                $installedExts = @($rawExts | ForEach-Object { $_.ToString().Trim().ToLowerInvariant() } | Where-Object { $_ })
            }
        } catch {}

        foreach ($ext in $requiredExtensions) {
            if ($installedExts -contains $ext.ToLowerInvariant()) {
                Write-Ok "VS Code extension already installed: $ext"
            } else {
                Write-Info "Installing VS Code extension: $ext..."
                & $codeCmd --install-extension $ext --force
                if ($LASTEXITCODE -eq 0) {
                    $extensionsInstalledNow += $ext
                } else {
                    Write-Info "Extension install returned exit code $LASTEXITCODE for $ext."
                }
            }
        }

        $finalExts = @()
        $finalListOk = $false
        try {
            $rawFinal = & $codeCmd --list-extensions 2>$null
            if ($LASTEXITCODE -eq 0) {
                $finalListOk = $true
                if ($rawFinal) {
                    $finalExts = @($rawFinal | ForEach-Object { $_.ToString().Trim().ToLowerInvariant() } | Where-Object { $_ })
                }
            }
        } catch {}

        if ($finalListOk) {
            foreach ($ext in $requiredExtensions) {
                if ($finalExts -notcontains $ext.ToLowerInvariant()) {
                    $missingExtensions += $ext
                }
            }
        }

        if ($missingExtensions.Count -eq 0) {
            Write-Ok "VS Code Python, Jupyter & Data Wrangler extensions ready."
        } else {
            Write-Info "Missing VS Code extension(s): $($missingExtensions -join ', '). You can install them from the Extensions tab in VS Code."
        }
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

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = if ($scriptPath) { Split-Path -Parent $scriptPath } else { (Get-Location).Path }
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
    $parentDir = Join-Path $env:USERPROFILE "Courses"
    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
    if (-not $parentDir -or -not (Test-Path $parentDir)) {
        $parentDir = $HOME
    }
    $baseRepoRoot = Join-Path $parentDir $TargetDirName
    $repoRoot = $baseRepoRoot
    if (Test-Path $repoRoot) {
        $ver = 2
        while (Test-Path "${baseRepoRoot}_v${ver}") { $ver++ }
        $repoRoot = "${baseRepoRoot}_v${ver}"
        Write-Info "Existing folder found at $baseRepoRoot; creating fresh session folder: $repoRoot"
    }

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

    if ($hasGit) {
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
        if (-not $innerFolder) { throw "Failed to locate extracted repository folder in $extractDir." }
        if (-not (Test-Path $repoRoot)) { New-Item -ItemType Directory -Path $repoRoot | Out-Null }
        Copy-Item -Path "$($innerFolder.FullName)\*" -Destination $repoRoot -Recurse -Force
    }

    # Carry forward upstream Parquet outputs from the most recent previous lab folder (if any)
    $newSandbox = Join-Path $repoRoot "03_labs_student_starters\sandbox_outputs"
    $searchDirs = @($parentDir, (Join-Path $env:USERPROFILE "Documents")) | Where-Object { Test-Path $_ }
    $prevFolders = $searchDirs | ForEach-Object {
        Get-ChildItem -Path $_ -Directory -Filter "ife_bi_bigdata_student*" -ErrorAction SilentlyContinue
    } | Where-Object { $_.FullName -ne $repoRoot } | Sort-Object LastWriteTime -Descending
    foreach ($pf in $prevFolders) {
        $candSb = Join-Path $pf.FullName "03_labs_student_starters\sandbox_outputs"
        if (Test-Path $candSb) {
            $pqs = Get-ChildItem -Path $candSb -Filter "*.parquet" -Recurse -File -ErrorAction SilentlyContinue
            if ($pqs) {
                Write-Info "Copying previous Parquet sandbox_outputs from $candSb..."
                foreach ($pq in $pqs) {
                    $relPath = $pq.FullName.Substring($candSb.Length).TrimStart([char[]]@('\', '/'))
                    $destFile = Join-Path $newSandbox $relPath
                    $destDir = Split-Path -Parent $destFile
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                    Copy-Item -Path $pq.FullName -Destination $destFile -Force
                }
                Write-Ok "Carried forward previous sandbox_outputs/*.parquet into new session folder."
                break
            }
        }
    }

    Write-Ok "Course files ready at: $repoRoot"
}

# ---------------------------------------------------------------------------
# STEP 5: Create Virtual Environment (.venv) & Install Dependencies
# ---------------------------------------------------------------------------
Write-Step "STEP 5: Creating Virtual Environment (.venv) & Installing Packages"

if ($repoRoot -like "*OneDrive*") {
    Write-Info "Note: Your course folder appears to be inside OneDrive ($repoRoot)."
    Write-Info "OneDrive sync can sometimes lock or offload .venv files. Recommended location: $env:USERPROFILE\Courses\$TargetDirName"
}

Push-Location $repoRoot
$venvDir = Join-Path $repoRoot ".venv"
$venvPython = Join-Path $venvDir "Scripts\python.exe"

if (-not (Test-Path $venvPython)) {
    Write-Info "Creating virtual environment in $venvDir..."
    & $pythonExe -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Virtual environment creation failed (exit code $LASTEXITCODE)."
        Pop-Location
        if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
    }
}

if (-not (Test-Path $venvPython)) {
    Write-Err "Failed to create .venv at $venvDir"
    Pop-Location
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}

# Verify pip is present inside .venv (guards against half-created venvs where ensurepip failed)
$hasVenvPip = $false
try {
    & $venvPython -m pip --version 2>$null | Out-Null
    $hasVenvPip = ($LASTEXITCODE -eq 0)
} catch {
    $hasVenvPip = $false
}
if (-not $hasVenvPip) {
    Write-Info "pip not found inside .venv; bootstrapping with ensurepip..."
    & $venvPython -m ensurepip --upgrade
    if ($LASTEXITCODE -ne 0) {
        Write-Err "pip is not available inside $venvDir. Delete the .venv folder and re-run setup."
        Pop-Location
        if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
    }
}
Write-Ok "Virtual environment ready: $venvPython"

# Neutralize user-level PIP_USER / pip.ini user=true overrides that break installs inside .venv
$prevPipUser = $env:PIP_USER
$prevPipReqVenv = $env:PIP_REQUIRE_VIRTUALENV
try {
    $env:PIP_USER = "0"
    $env:PIP_REQUIRE_VIRTUALENV = "0"

    Write-Info "Upgrading pip and installing course requirements (pandas, duckdb, pyarrow, plotly, jupyter, ipykernel)..."
    & $venvPython -m pip install --upgrade pip --retries 5 --timeout 60
    if ($LASTEXITCODE -ne 0) {
        Write-Info "pip self-upgrade returned exit code $LASTEXITCODE; continuing with existing pip in .venv."
    }

    $pipInstallArgs = @("-m", "pip", "install", "--prefer-binary", "--retries", "10", "--timeout", "60", "-r", "requirements.txt", "ipykernel")
    & $venvPython @pipInstallArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Info "Package installation returned exit code $LASTEXITCODE. Retrying once..."
        Start-Sleep -Seconds 3
        & $venvPython @pipInstallArgs
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Failed to install required Python packages into .venv (exit code $LASTEXITCODE)."
        Write-Host "  Manual retry command (no terminal activation needed):" -ForegroundColor Yellow
        Write-Host "    `"$venvPython`" -m pip install --prefer-binary -r requirements.txt ipykernel" -ForegroundColor Yellow
        Pop-Location
        if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
    }
    Write-Ok "All required Python packages installed into .venv."
} finally {
    if ($null -eq $prevPipUser) { Remove-Item Env:PIP_USER -ErrorAction SilentlyContinue } else { $env:PIP_USER = $prevPipUser }
    if ($null -eq $prevPipReqVenv) { Remove-Item Env:PIP_REQUIRE_VIRTUALENV -ErrorAction SilentlyContinue } else { $env:PIP_REQUIRE_VIRTUALENV = $prevPipReqVenv }
}

Write-Info "Registering .venv as a Jupyter Notebook Kernel..."
& $venvPython -m ipykernel install --user --name "ife-bi-venv" --display-name "Python (.venv - BI & Big Data)"
if ($LASTEXITCODE -ne 0) {
    Write-Err "Failed to register Jupyter kernel (exit code $LASTEXITCODE)."
    Pop-Location
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}
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
    "python.terminal.activateEnvInCurrentTerminal": true,
    "jupyter.jupyterServerType": "local"
}
'@
[System.IO.File]::WriteAllText((Join-Path $vscodeDir "settings.json"), $settingsJson, (New-Object System.Text.UTF8Encoding($false)))
Write-Ok "Configured .vscode/settings.json to auto-select .venv interpreter."

# ---------------------------------------------------------------------------
# STEP 6: Verify Environment & Raw Bronze Datasets
# ---------------------------------------------------------------------------
Write-Step "STEP 6: Running Environment & Data Verification"

$verifyOk = $true
if (Test-Path (Join-Path $repoRoot "verify_environment.py")) {
    & $venvPython verify_environment.py
    if ($LASTEXITCODE -ne 0) {
        $verifyOk = $false
    }
}

Pop-Location

if (-not $verifyOk) {
    Write-Err "Environment verification reported errors (see [FAIL] items above)."
    Write-Info "Please review the output above or re-run the setup script before opening notebooks in VS Code."
    Write-Host "  Workspace folder : $repoRoot" -ForegroundColor Yellow
    Write-Host "  Manual fix       : `"$venvPython`" -m pip install --prefer-binary -r `"$repoRoot\requirements.txt`" ipykernel" -ForegroundColor Yellow
    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
}

Write-Host ""
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host "  IMPORTANT WHEN VS CODE OPENS:" -ForegroundColor Yellow
Write-Host "  1. When prompted 'Do you trust the authors of the files in this" -ForegroundColor Yellow
Write-Host "     folder?', check 'Trust the authors of all files in the parent" -ForegroundColor Yellow
Write-Host "     folder Courses' and click 'Yes, I trust the authors'." -ForegroundColor Yellow
Write-Host "     (In Restricted Mode, VS Code hides .venv from Jupyter kernels" -ForegroundColor Yellow
Write-Host "     and disables automatic terminal activation!)" -ForegroundColor Yellow
if ($vscodeWasRunning -and ($pythonInstalledThisRun -or $extensionsInstalledNow.Count -gt 0)) {
    Write-Host "  2. VS Code was already open while Python/extensions were updated." -ForegroundColor Yellow
    Write-Host "     Please CLOSE ALL VS Code windows and reopen this folder if" -ForegroundColor Yellow
    Write-Host "     '.venv' does not appear in Select Kernel immediately." -ForegroundColor Yellow
}
Write-Host "====================================================================" -ForegroundColor Yellow

if ($codeCmd) {
    Write-Info "Launching Visual Studio Code in $repoRoot..."
    Start-Process -FilePath $codeCmd -ArgumentList "`"$repoRoot`""
}

Write-Host "`nAll done! You can close this window and work inside VS Code." -ForegroundColor Green
