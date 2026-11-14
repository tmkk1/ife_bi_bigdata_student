#!/usr/bin/env bash
# ==============================================================================
# Automated Student Environment Setup Script for Linux (Ubuntu/Debian/Fedora/Arch)
# Course: Business Intelligence and Big Data Analysis (01 31 0367 00) - IFE, TUL
# ==============================================================================
# Features:
#   - Supports Ubuntu/Debian (apt), Fedora/RHEL (dnf), Arch (pacman), openSUSE (zypper)
#   - Works both inside an already cloned repo and standalone via curl | bash
#   - Checks Python 3.11+ WITH working venv & ensurepip modules
#   - Creates .venv inside ~/Courses/ife_bi_bigdata_student, installs wheels,
#     registers the Jupyter kernel, and configures VS Code settings
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

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
fi

# ------------------------------------------------------------------------------
# STEP 1: Evaluate Local Linux Environment
# ------------------------------------------------------------------------------
step "STEP 1: Evaluating Local Linux Environment"

DISTRO_NAME="Linux"
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_NAME="${PRETTY_NAME:-${NAME:-Linux}}"
fi
ARCH="$(uname -m)"
echo "  Distribution  : ${DISTRO_NAME}"
echo "  Architecture  : ${ARCH}"

PKG_MGR=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
elif command -v zypper >/dev/null 2>&1; then
    PKG_MGR="zypper"
fi
if [ -n "$PKG_MGR" ]; then
    ok "Package manager detected: ${PKG_MGR}"
else
    info "No supported system package manager detected; assuming Python 3.11+ and git are pre-installed."
fi

# ------------------------------------------------------------------------------
# STEP 2: Check / Install Python (Requires Python 3.11+ with venv & ensurepip)
# ------------------------------------------------------------------------------
step "STEP 2: Checking Python Installation (Requires Python 3.11+)"

PYTHON_EXE=""
find_valid_python() {
    local cand
    for cand in python3.12 python3.11 python3.13 python3 python; do
        if command -v "$cand" >/dev/null 2>&1; then
            local resolved
            resolved="$(command -v "$cand")"
            if "$resolved" -c "import sys, venv, ensurepip; sys.exit(0 if sys.version_info >= (3, 11) else 1)" >/dev/null 2>&1; then
                PYTHON_EXE="$resolved"
                ok "Found compatible Python: ${PYTHON_EXE} ($("$PYTHON_EXE" --version))"
                return 0
            fi
        fi
    done
    return 1
}

if ! find_valid_python; then
    info "Python 3.11+ with working venv/ensurepip was not found. Attempting system package install..."
    case "$PKG_MGR" in
        apt)
            $SUDO apt-get update -y
            $SUDO apt-get install -y python3 python3-venv python3-pip curl git unzip
            ;;
        dnf)
            $SUDO dnf install -y python3 python3-pip curl git unzip
            ;;
        pacman)
            $SUDO pacman -Sy --noconfirm python python-pip curl git unzip
            ;;
        zypper)
            $SUDO zypper --non-interactive install python311 python311-pip curl git unzip || \
                $SUDO zypper --non-interactive install python3 python3-pip curl git unzip
            ;;
        *)
            err "Automatic Python installation is unsupported on this distribution."
            err "Please install Python 3.11+ (with venv and pip), git, and curl, then re-run."
            exit 1
            ;;
    esac
    find_valid_python || true
fi

if [ -z "$PYTHON_EXE" ]; then
    # Handle Ubuntu/Debian where python3.12 exists but needs python3.12-venv specifically
    if [ "$PKG_MGR" = "apt" ] && command -v python3 >/dev/null 2>&1; then
        PY_MINOR="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
        if [ -n "$PY_MINOR" ]; then
            info "Installing python${PY_MINOR}-venv..."
            $SUDO apt-get install -y "python${PY_MINOR}-venv" || true
            find_valid_python || true
        fi
    fi
fi

if [ -z "$PYTHON_EXE" ]; then
    err "Could not locate Python 3.11+ with working venv/ensurepip."
    err "Install Python 3.11 or 3.12 (plus python3-venv on Debian/Ubuntu) and re-run."
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 3: Check Visual Studio Code & Extensions (Optional)
# ------------------------------------------------------------------------------
step "STEP 3: Checking Visual Studio Code"

CODE_CLI=""
if command -v code >/dev/null 2>&1; then
    CODE_CLI="$(command -v code)"
    ok "VS Code CLI found: ${CODE_CLI}"
    info "Ensuring Python, Jupyter and Data Wrangler VS Code extensions are installed..."
    "$CODE_CLI" --install-extension ms-python.python >/dev/null 2>&1 || true
    "$CODE_CLI" --install-extension ms-toolsai.jupyter >/dev/null 2>&1 || true
    "$CODE_CLI" --install-extension ms-toolsai.datawrangler >/dev/null 2>&1 || true
    ok "VS Code extensions configured."
else
    info "VS Code ('code' CLI) not found in PATH."
    info "You can install VS Code from https://code.visualstudio.com/download (or use JupyterLab via .venv)."
fi

# ------------------------------------------------------------------------------
# STEP 4: Locate or Clone Course Repository
# ------------------------------------------------------------------------------
step "STEP 4: Setting Up Course Workspace"

SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
if [ -n "${SCRIPT_SOURCE}" ] && [ -f "${SCRIPT_SOURCE}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SOURCE}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

if [ -f "${SCRIPT_DIR}/requirements.txt" ] && [ -d "${SCRIPT_DIR}/03_labs_student_starters" ]; then
    REPO_ROOT="$SCRIPT_DIR"
    ok "Running inside existing course workspace: ${REPO_ROOT}"
    if [ -d "${REPO_ROOT}/.git" ] && command -v git >/dev/null 2>&1; then
        info "Checking for remote updates (git pull --ff-only)..."
        (cd "$REPO_ROOT" && git pull --ff-only) || info "Keeping existing local files."
    fi
else
    mkdir -p "${HOME}/Courses"
    REPO_ROOT="${HOME}/Courses/${TARGET_DIR_NAME}"

    if ! command -v git >/dev/null 2>&1 && [ -n "$PKG_MGR" ]; then
        info "Git not found; attempting to install git..."
        case "$PKG_MGR" in
            apt) $SUDO apt-get install -y git curl unzip || true ;;
            dnf) $SUDO dnf install -y git curl unzip || true ;;
            pacman) $SUDO pacman -S --noconfirm git curl unzip || true ;;
            zypper) $SUDO zypper --non-interactive install git curl unzip || true ;;
        esac
    fi

    if command -v git >/dev/null 2>&1; then
        if [ -d "${REPO_ROOT}/.git" ]; then
            info "Repository already exists at ${REPO_ROOT}. Pulling latest changes..."
            (cd "$REPO_ROOT" && git pull --ff-only) || true
        else
            info "Cloning student repository from ${REPO_URL} into ${REPO_ROOT}..."
            git clone "$REPO_URL" "$REPO_ROOT"
        fi
    else
        info "Git not available; downloading repository ZIP archive via curl..."
        ZIP_URL="${REPO_URL%.git}/archive/refs/heads/main.zip"
        TMP_ZIP="$(mktemp /tmp/ife_bi_repo_XXXXXX.zip)"
        TMP_EXTRACT="$(mktemp -d /tmp/ife_bi_extract_XXXXXX)"
        curl -fSL "$ZIP_URL" -o "$TMP_ZIP"
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

if [ -n "$CODE_CLI" ] && [ -z "${SSH_CONNECTION:-}" ] && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
    info "Launching Visual Studio Code in ${REPO_ROOT}..."
    "$CODE_CLI" "$REPO_ROOT" >/dev/null 2>&1 || true
fi

step "SETUP COMPLETE!"
echo "  Workspace folder : ${REPO_ROOT}"
echo "  Python .venv     : ${VENV_PYTHON}"
echo "  Open this folder in VS Code and select the 'Python (.venv - BI & Big Data)' kernel."
echo ""
