#!/usr/bin/env bash
# ==============================================================================
# Automated Student Environment Setup Script for macOS (Intel & Apple Silicon)
# Course: Business Intelligence and Big Data Analysis (01 31 0367 00) - IFE, TUL
# ==============================================================================
# Features:
#   - Works on both Apple Silicon (M1/M2/M3/M4) and Intel Macs
#   - Works WITH or WITHOUT Xcode Command Line Tools (avoids the 20-minute
#     Xcode CLT download trap by using official universal2 binaries & curl/unzip
#     when Xcode CLT is absent!)
#   - Installs Python 3.12, VS Code, .venv, course libraries, and Jupyter kernel
# ==============================================================================

set -euo pipefail

REPO_URL="${1:-https://github.com/tmkk1/ife_bi_bigdata_student.git}"
TARGET_DIR_NAME="${2:-ife_bi_bigdata_student}"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() {
    echo ""
    echo -e "${CYAN}====================================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}====================================================================${NC}"
}

ok()   { echo -e "  ${GREEN}[OK]${NC}   $1"; }
info() { echo -e "  ${YELLOW}[INFO]${NC} $1"; }
err()  { echo -e "  ${RED}[FAIL]${NC} $1"; }

# ------------------------------------------------------------------------------
# STEP 1: Evaluate Local macOS Environment
# ------------------------------------------------------------------------------
step "STEP 1: Evaluating Local macOS Environment"

OS_VER="$(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
ARCH="$(uname -m)"
echo "  macOS Version : ${OS_VER}"
echo "  Architecture  : ${ARCH}"

HAS_XCODE_CLT=0
if xcode-select -p >/dev/null 2>&1; then
    HAS_XCODE_CLT=1
    ok "Xcode Command Line Tools are installed ($(xcode-select -p))."
else
    info "Xcode Command Line Tools are NOT installed."
    info "Bypassing /usr/bin/python3 and /usr/bin/git shims so we don't get stuck waiting for Xcode download!"
fi

HAS_BREW=0
BREW_BIN=""
if [ -x "/opt/homebrew/bin/brew" ]; then
    HAS_BREW=1
    BREW_BIN="/opt/homebrew/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    HAS_BREW=1
    BREW_BIN="/usr/local/bin/brew"
    eval "$(/usr/local/bin/brew shellenv)"
elif command -v brew >/dev/null 2>&1; then
    HAS_BREW=1
    BREW_BIN="$(command -v brew)"
fi

if [ "$HAS_BREW" -eq 1 ]; then
    ok "Homebrew is available (${BREW_BIN})."
else
    info "Homebrew not detected (not required; official standalone installers will be used)."
fi

# ------------------------------------------------------------------------------
# STEP 2: Check / Install Python (Requires Python 3.10+)
# ------------------------------------------------------------------------------
step "STEP 2: Checking Python Installation (Requires Python 3.10+)"

PYTHON_EXE=""

find_valid_python() {
    local candidates=(
        "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3"
        "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"
        "/Library/Frameworks/Python.framework/Versions/3.13/bin/python3"
        "/Library/Frameworks/Python.framework/Versions/3.10/bin/python3"
        "/opt/homebrew/bin/python3.12"
        "/opt/homebrew/bin/python3.11"
        "/opt/homebrew/bin/python3.13"
        "/opt/homebrew/bin/python3.10"
        "/opt/homebrew/bin/python3"
        "/usr/local/bin/python3.12"
        "/usr/local/bin/python3.11"
        "/usr/local/bin/python3.13"
        "/usr/local/bin/python3.10"
        "/usr/local/bin/python3"
    )
    # Only check /usr/bin/python3 if Xcode CLT is actually installed (otherwise it pops up a blocking GUI dialog!)
    if [ "$HAS_XCODE_CLT" -eq 1 ]; then
        candidates+=("/usr/bin/python3")
    fi

    for cand in "${candidates[@]}"; do
        if [ -x "$cand" ]; then
            if "$cand" -c "import sys, venv; sys.exit(0 if sys.version_info >= (3, 10) else 1)" >/dev/null 2>&1; then
                PYTHON_EXE="$cand"
                return 0
            fi
        fi
    done
    return 1
}

if ! find_valid_python; then
    info "Python 3.10+ not found. Installing official Python 3.12 (universal2 macOS package, no Xcode required)..."
    PKG_URL="https://www.python.org/ftp/python/3.12.7/python-3.12.7-macos11.pkg"
    PKG_PATH="/tmp/python-3.12.7-macos11.pkg"
    curl -fSL "$PKG_URL" -o "$PKG_PATH"

    info "Installing Python 3.12 into /Library/Frameworks (you may be prompted for your Mac login password)..."
    if sudo installer -pkg "$PKG_PATH" -target /; then
        ok "Python 3.12 package installed successfully."
    else
        info "Opening Python installer window. Please complete the installer steps and wait..."
        open -W "$PKG_PATH"
    fi

    # Install SSL certificates bundled with python.org macOS installer
    CERT_CMD="/Applications/Python 3.12/Install Certificates.command"
    if [ -f "$CERT_CMD" ]; then
        sh "$CERT_CMD" >/dev/null 2>&1 || true
    fi

    find_valid_python || true
fi

if [ -z "$PYTHON_EXE" ]; then
    err "Could not locate Python 3.10+ after installation. Please install Python 3.12 from https://www.python.org/downloads/macos/ and re-run this script."
    exit 1
fi

PY_VER="$("$PYTHON_EXE" --version)"
ok "Using ${PY_VER} at: ${PYTHON_EXE}"

# Ensure SSL certificates are configured if using python.org framework build
PY_SHORT_VER="$("$PYTHON_EXE" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")"
if [ -f "/Applications/Python ${PY_SHORT_VER}/Install Certificates.command" ]; then
    sh "/Applications/Python ${PY_SHORT_VER}/Install Certificates.command" >/dev/null 2>&1 || true
fi

# ------------------------------------------------------------------------------
# STEP 3: Check / Install Visual Studio Code
# ------------------------------------------------------------------------------
step "STEP 3: Checking Visual Studio Code"

CODE_APP=""
if [ -d "/Applications/Visual Studio Code.app" ]; then
    CODE_APP="/Applications/Visual Studio Code.app"
elif [ -d "$HOME/Applications/Visual Studio Code.app" ]; then
    CODE_APP="$HOME/Applications/Visual Studio Code.app"
fi

if [ -z "$CODE_APP" ]; then
    info "Visual Studio Code not found. Downloading VS Code Universal for macOS..."
    VSCODE_ZIP="/tmp/VSCode-darwin-universal.zip"
    curl -fSL "https://update.code.visualstudio.com/latest/darwin-universal/stable" -o "$VSCODE_ZIP"
    info "Extracting Visual Studio Code to /Applications..."
    if unzip -q -o "$VSCODE_ZIP" -d "/Applications" 2>/dev/null; then
        CODE_APP="/Applications/Visual Studio Code.app"
    else
        mkdir -p "$HOME/Applications"
        unzip -q -o "$VSCODE_ZIP" -d "$HOME/Applications"
        CODE_APP="$HOME/Applications/Visual Studio Code.app"
    fi
    xattr -dr com.apple.quarantine "$CODE_APP" 2>/dev/null || true
    rm -f "$VSCODE_ZIP"
fi

CODE_CLI="${CODE_APP}/Contents/Resources/app/bin/code"
if [ -x "$CODE_CLI" ]; then
    ok "VS Code found at: ${CODE_APP}"
    info "Installing required VS Code extensions (Python & Jupyter)..."
    "$CODE_CLI" --install-extension ms-python.python --force >/dev/null 2>&1 || true
    "$CODE_CLI" --install-extension ms-toolsai.jupyter --force >/dev/null 2>&1 || true
    ok "VS Code Python & Jupyter extensions installed."
else
    info "VS Code CLI binary not found; you can install extensions manually inside VS Code."
fi

# ------------------------------------------------------------------------------
# STEP 4: Sync Course Repository Structure
# ------------------------------------------------------------------------------
step "STEP 4: Setting Up Course Directory Structure & Files"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we are already inside the course repository
if [ -f "${SCRIPT_DIR}/requirements.txt" ] && [ -d "${SCRIPT_DIR}/03_labs_student_starters" ]; then
    REPO_ROOT="$SCRIPT_DIR"
    ok "Already running inside course repository: ${REPO_ROOT}"
    if [ -d "${REPO_ROOT}/.git" ] && [ "$HAS_XCODE_CLT" -eq 1 ]; then
        info "Pulling latest updates from Git remote..."
        (cd "$REPO_ROOT" && git pull --ff-only) || info "Keeping existing local files."
    fi
else
    REPO_ROOT="${HOME}/Documents/${TARGET_DIR_NAME}"
    if [ ! -d "${HOME}/Documents" ]; then
        REPO_ROOT="${HOME}/${TARGET_DIR_NAME}"
    fi

    # Determine if real Git is available without triggering Xcode CLT popup
    REAL_GIT=""
    if [ -x "/opt/homebrew/bin/git" ]; then
        REAL_GIT="/opt/homebrew/bin/git"
    elif [ -x "/usr/local/bin/git" ]; then
        REAL_GIT="/usr/local/bin/git"
    elif [ "$HAS_XCODE_CLT" -eq 1 ] && [ -x "/usr/bin/git" ]; then
        REAL_GIT="/usr/bin/git"
    fi

    if [ -n "$REAL_GIT" ]; then
        if [ -d "${REPO_ROOT}/.git" ]; then
            info "Repository already exists at ${REPO_ROOT}. Pulling latest changes..."
            (cd "$REPO_ROOT" && "$REAL_GIT" pull --ff-only) || true
        else
            info "Cloning student repository from ${REPO_URL} into ${REPO_ROOT}..."
            "$REAL_GIT" clone "$REPO_URL" "$REPO_ROOT"
        fi
    else
        info "Git/Xcode CLT not installed; downloading repository ZIP directly via curl..."
        ZIP_URL="${REPO_URL%.git}/archive/refs/heads/main.zip"
        TMP_ZIP="/tmp/ife_bi_course.zip"
        TMP_EXTRACT="/tmp/ife_bi_course_extract"
        curl -fSL "$ZIP_URL" -o "$TMP_ZIP"
        rm -rf "$TMP_EXTRACT"
        mkdir -p "$TMP_EXTRACT"
        unzip -q "$TMP_ZIP" -d "$TMP_EXTRACT"
        INNER_DIR="$(find "$TMP_EXTRACT" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
        mkdir -p "$REPO_ROOT"
        cp -R "${INNER_DIR}/." "$REPO_ROOT/"
        rm -rf "$TMP_ZIP" "$TMP_EXTRACT"
    fi
    ok "Course files ready at: ${REPO_ROOT}"
fi

# ------------------------------------------------------------------------------
# STEP 5: Create Virtual Environment (.venv) & Install Dependencies
# ------------------------------------------------------------------------------
step "STEP 5: Creating Virtual Environment (.venv) & Installing Packages"

cd "$REPO_ROOT"
VENV_DIR="${REPO_ROOT}/.venv"
VENV_PYTHON="${VENV_DIR}/bin/python"

if [ ! -x "$VENV_PYTHON" ]; then
    info "Creating virtual environment in ${VENV_DIR}..."
    "$PYTHON_EXE" -m venv .venv
fi

ok "Virtual environment ready: ${VENV_PYTHON}"

info "Upgrading pip and installing course packages (using pre-built binary wheels)..."
"$VENV_PYTHON" -m pip install --upgrade pip
"$VENV_PYTHON" -m pip install --prefer-binary -r requirements.txt ipykernel

info "Registering .venv as a Jupyter Notebook Kernel..."
"$VENV_PYTHON" -m ipykernel install --user --name "ife-bi-venv" --display-name "Python (.venv - BI & Big Data)"
ok "Jupyter Kernel registered."

mkdir -p "${REPO_ROOT}/.vscode"
cat > "${REPO_ROOT}/.vscode/settings.json" << 'EOF'
{
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "jupyter.jupyterServerType": "local"
}
EOF
ok "Configured .vscode/settings.json to auto-select .venv interpreter."

# ------------------------------------------------------------------------------
# STEP 6: Verify Environment & Raw Bronze Datasets
# ------------------------------------------------------------------------------
step "STEP 6: Running Environment & Data Verification"

if [ -f "${REPO_ROOT}/verify_environment.py" ]; then
    "$VENV_PYTHON" "${REPO_ROOT}/verify_environment.py"
fi

if [ -x "$CODE_CLI" ]; then
    info "Launching Visual Studio Code in ${REPO_ROOT}..."
    "$CODE_CLI" "$REPO_ROOT" || open -a "$CODE_APP" "$REPO_ROOT" || true
elif [ -n "$CODE_APP" ]; then
    open -a "$CODE_APP" "$REPO_ROOT" || true
fi

echo ""
echo -e "${GREEN}All done! Visual Studio Code is opening your project folder.${NC}"
