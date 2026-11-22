#!/usr/bin/env bash
# ==============================================================================
# Automated Student Environment Setup Script for Linux (Ubuntu/Debian/Fedora/Arch)
# Course: Business Intelligence and Big Data Analysis (01 31 0367 00) - IFE, TUL
# ==============================================================================
# Features:
#   - Supports Ubuntu/Debian (apt), Fedora/RHEL (dnf), Arch (pacman), openSUSE (zypper)
#   - Works both inside an already cloned repo and standalone via curl | bash
#   - Checks/installs Python 3.11-3.13 (preferred for binary wheels) WITH venv & ensurepip
#   - Detects/installs Visual Studio Code and verifies Python, Jupyter & Data Wrangler extensions
#   - Creates .venv inside ~/Courses/ife_bi_bigdata_student_YYYY-MM-DD, installs wheels,
#     registers the Jupyter kernel, and configures VS Code settings
# ==============================================================================

set -euo pipefail

REPO_URL="${1:-https://github.com/tmkk1/ife_bi_bigdata_student.git}"
TODAY_STR="$(date +%Y-%m-%d)"
TARGET_DIR_NAME="${2:-ife_bi_bigdata_student_${TODAY_STR}}"

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

if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    err "Please do NOT run this script with 'sudo'."
    err "Running as root would make ~/Courses, .venv, and VS Code extensions owned by root."
    err "Re-run as your normal user (the script uses sudo only for system package commands)."
    exit 1
fi

run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        err "Administrator privileges (sudo) are required for: $*"
        return 1
    fi
}

APT_UPDATED=0
apt_update_once() {
    if [ "$APT_UPDATED" -eq 0 ]; then
        run_privileged apt-get update -y
        APT_UPDATED=1
    fi
}

ensure_cmd() {
    local bin="$1"
    local pkg_apt="${2:-$1}"
    local pkg_dnf="${3:-$1}"
    local pkg_pacman="${4:-$1}"
    local pkg_zypper="${5:-$1}"

    if command -v "$bin" >/dev/null 2>&1; then
        return 0
    fi
    [ -z "${PKG_MGR:-}" ] && return 1

    info "Installing missing utility '${bin}'..."
    case "$PKG_MGR" in
        apt)
            apt_update_once && run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg_apt"
            ;;
        dnf)
            run_privileged dnf install -y "$pkg_dnf"
            ;;
        pacman)
            run_privileged pacman -Sy --noconfirm "$pkg_pacman"
            ;;
        zypper)
            run_privileged zypper --non-interactive install "$pkg_zypper"
            ;;
        *)
            return 1
            ;;
    esac
    command -v "$bin" >/dev/null 2>&1
}

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

IS_WSL=0
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then
    IS_WSL=1
    info "WSL2 environment detected."
fi

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
# STEP 2: Check / Install Python (Requires Python 3.11+, 3.11-3.13 Preferred)
# ------------------------------------------------------------------------------
step "STEP 2: Checking Python Installation (Requires Python 3.11+)"

PYTHON_EXE=""
find_valid_python() {
    local mode="${1:-preferred}"
    local py_check
    if [ "$mode" = "any" ]; then
        py_check="import sys, venv, ensurepip; sys.exit(0 if sys.version_info >= (3, 11) else 1)"
    else
        py_check="import sys, venv, ensurepip; sys.exit(0 if (3, 11) <= sys.version_info < (3, 14) else 1)"
    fi

    local cand
    for cand in python3.12 python3.11 python3.13 python3 python; do
        if command -v "$cand" >/dev/null 2>&1; then
            local resolved
            resolved="$(command -v "$cand")"
            if "$resolved" -c "$py_check" >/dev/null 2>&1; then
                PYTHON_EXE="$resolved"
                ok "Found compatible Python: ${PYTHON_EXE} ($("$PYTHON_EXE" --version))"
                return 0
            fi
        fi
    done
    return 1
}

if ! find_valid_python "preferred"; then
    if [ -n "$PKG_MGR" ]; then
        info "Python 3.11-3.13 with working venv/ensurepip was not found. Attempting system package install..."
        case "$PKG_MGR" in
            apt)
                apt_update_once
                run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip curl git unzip || true
                ;;
            dnf)
                run_privileged dnf install -y python3 python3-pip curl git unzip || true
                ;;
            pacman)
                run_privileged pacman -Sy --noconfirm python python-pip curl git unzip || true
                ;;
            zypper)
                run_privileged zypper --non-interactive install python311 python311-pip curl git unzip || \
                    run_privileged zypper --non-interactive install python3 python3-pip curl git unzip || true
                ;;
        esac
        find_valid_python "preferred" || true
    fi
fi

if [ -z "$PYTHON_EXE" ]; then
    # Handle Ubuntu/Debian where python3.12 exists but needs python3.12-venv specifically
    if [ "$PKG_MGR" = "apt" ] && command -v python3 >/dev/null 2>&1; then
        PY_MINOR="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
        if [ -n "$PY_MINOR" ]; then
            info "Installing python${PY_MINOR}-venv..."
            apt_update_once || true
            run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "python${PY_MINOR}-venv" || true
            find_valid_python "preferred" || true
        fi
    fi
fi

if [ -z "$PYTHON_EXE" ]; then
    if find_valid_python "any"; then
        info "Using Python 3.14+ fallback. Pre-built binary wheels may be unavailable for some pinned packages."
    fi
fi

if [ -z "$PYTHON_EXE" ]; then
    err "Could not locate Python 3.11+ with working venv/ensurepip."
    err "Install Python 3.11, 3.12, or 3.13 (plus python3-venv on Debian/Ubuntu) and re-run."
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 3: Check / Install Visual Studio Code & Extensions
# ------------------------------------------------------------------------------
step "STEP 3: Checking & Installing Visual Studio Code"

REQUIRED_VSCODE_EXTS=(
    "ms-python.python"
    "ms-toolsai.jupyter"
    "ms-toolsai.datawrangler"
)
CODE_CLI=""
CODE_IS_FLATPAK=0
MISSING_VSCODE_EXTS=()

find_vscode() {
    CODE_CLI=""
    CODE_IS_FLATPAK=0

    if command -v code >/dev/null 2>&1; then
        CODE_CLI="$(command -v code)"
        return 0
    fi

    local cand
    for cand in \
        "/usr/bin/code" \
        "/snap/bin/code" \
        "/usr/local/bin/code" \
        "${HOME}/.local/bin/code" \
        "${HOME}/.local/opt/vscode/bin/code"; do
        if [ -x "$cand" ]; then
            CODE_CLI="$cand"
            return 0
        fi
    done

    if command -v flatpak >/dev/null 2>&1 && flatpak info com.visualstudio.code >/dev/null 2>&1; then
        CODE_CLI="flatpak"
        CODE_IS_FLATPAK=1
        return 0
    fi

    return 1
}

run_vscode() {
    if [ "$CODE_IS_FLATPAK" -eq 1 ]; then
        flatpak run com.visualstudio.code "$@"
    else
        "$CODE_CLI" "$@"
    fi
}

install_vscode_tarball() {
    local vscode_arch="$1"
    ensure_cmd tar tar tar tar tar || true
    if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
        info "Cannot install VS Code user tarball without curl and tar."
        return 1
    fi

    local tmp_tgz
    tmp_tgz="$(mktemp /tmp/vscode_XXXXXX.tar.gz)"
    local tgz_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-${vscode_arch}"
    info "Downloading official VS Code archive (${vscode_arch}) into ~/.local/opt/vscode..."
    if ! curl -fSL "$tgz_url" -o "$tmp_tgz"; then
        rm -f "$tmp_tgz"
        info "Failed to download VS Code archive from ${tgz_url}."
        return 1
    fi

    mkdir -p "${HOME}/.local/opt/vscode" "${HOME}/.local/bin" "${HOME}/.local/share/applications"
    if ! tar -xzf "$tmp_tgz" --strip-components=1 -C "${HOME}/.local/opt/vscode"; then
        rm -f "$tmp_tgz"
        info "Failed to extract VS Code archive."
        return 1
    fi
    rm -f "$tmp_tgz"

    ln -sf "${HOME}/.local/opt/vscode/bin/code" "${HOME}/.local/bin/code"
    export PATH="${HOME}/.local/bin:${PATH}"

    cat > "${HOME}/.local/share/applications/code.desktop" << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=${HOME}/.local/opt/vscode/code %F
Icon=${HOME}/.local/opt/vscode/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
EOF

    ok "Installed VS Code into ${HOME}/.local/opt/vscode (linked at ~/.local/bin/code)."
    return 0
}

install_vscode_linux() {
    local vscode_arch=""
    case "$ARCH" in
        x86_64|amd64) vscode_arch="x64" ;;
        aarch64|arm64) vscode_arch="arm64" ;;
        armv7l|armhf) vscode_arch="armhf" ;;
        *)
            info "Automatic VS Code installation is not available for architecture '${ARCH}'."
            return 1
            ;;
    esac

    ensure_cmd curl curl curl curl curl || true
    if ! command -v curl >/dev/null 2>&1; then
        info "curl is not available; cannot download VS Code automatically."
        return 1
    fi

    local native_ok=0
    case "$PKG_MGR" in
        apt)
            local tmp_deb
            tmp_deb="$(mktemp /tmp/vscode_XXXXXX.deb)"
            local deb_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-${vscode_arch}"
            info "Downloading official VS Code .deb package (${vscode_arch})..."
            if curl -fSL "$deb_url" -o "$tmp_deb"; then
                echo "code code/add-microsoft-repo boolean true" | run_privileged debconf-set-selections >/dev/null 2>&1 || true
                if apt_update_once && run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp_deb"; then
                    native_ok=1
                    ok "VS Code installed via apt."
                else
                    info "System .deb installation failed or lacked privileges; falling back to user-local install."
                fi
            else
                info "Failed to download VS Code .deb package; falling back to user-local install."
            fi
            rm -f "$tmp_deb"
            ;;
        dnf)
            if [ "$vscode_arch" = "x64" ] || [ "$vscode_arch" = "arm64" ]; then
                local tmp_rpm
                tmp_rpm="$(mktemp /tmp/vscode_XXXXXX.rpm)"
                local rpm_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-${vscode_arch}"
                info "Downloading official VS Code .rpm package (${vscode_arch})..."
                if curl -fSL "$rpm_url" -o "$tmp_rpm"; then
                    run_privileged rpm --import https://packages.microsoft.com/keys/microsoft.asc >/dev/null 2>&1 || true
                    if run_privileged dnf install -y "$tmp_rpm"; then
                        native_ok=1
                        ok "VS Code installed via dnf."
                    else
                        info "System .rpm installation failed or lacked privileges; falling back to user-local install."
                    fi
                else
                    info "Failed to download VS Code .rpm package; falling back to user-local install."
                fi
                rm -f "$tmp_rpm"
            fi
            ;;
        zypper)
            if [ "$vscode_arch" = "x64" ] || [ "$vscode_arch" = "arm64" ]; then
                local tmp_rpm
                tmp_rpm="$(mktemp /tmp/vscode_XXXXXX.rpm)"
                local rpm_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-${vscode_arch}"
                info "Downloading official VS Code .rpm package (${vscode_arch})..."
                if curl -fSL "$rpm_url" -o "$tmp_rpm"; then
                    run_privileged rpm --import https://packages.microsoft.com/keys/microsoft.asc >/dev/null 2>&1 || true
                    if run_privileged zypper --non-interactive install --allow-unsigned-rpm "$tmp_rpm"; then
                        native_ok=1
                        ok "VS Code installed via zypper."
                    else
                        info "System .rpm installation failed or lacked privileges; falling back to user-local install."
                    fi
                else
                    info "Failed to download VS Code .rpm package; falling back to user-local install."
                fi
                rm -f "$tmp_rpm"
            fi
            ;;
        pacman)
            info "Arch Linux 'code' package is Code - OSS (missing Microsoft Data Wrangler); installing official VS Code tarball in ~/.local/opt/vscode..."
            ;;
    esac

    if [ "$native_ok" -eq 0 ] && ! find_vscode; then
        install_vscode_tarball "$vscode_arch" || return 1
    fi
    return 0
}

if ! find_vscode; then
    if [ "$IS_WSL" -eq 1 ]; then
        info "VS Code ('code' CLI) not detected inside WSL2."
        info "Do NOT install Linux desktop VS Code inside WSL2 — install VS Code on Windows (https://code.visualstudio.com/download) with the 'WSL' extension (ms-vscode-remote.remote-wsl) and open this folder from WSL via 'code .'."
    else
        info "VS Code not found. Attempting automatic installation..."
        install_vscode_linux || true
        find_vscode || true
    fi
fi

if [ -n "$CODE_CLI" ]; then
    if [ "$CODE_IS_FLATPAK" -eq 1 ]; then
        ok "VS Code found via Flatpak (com.visualstudio.code)."
    else
        ok "VS Code CLI found: ${CODE_CLI}"
    fi

    INSTALLED_EXTS="$(run_vscode --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
    for ext in "${REQUIRED_VSCODE_EXTS[@]}"; do
        ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
        if printf '%s\n' "$INSTALLED_EXTS" | grep -qx "$ext_lower"; then
            ok "VS Code extension already installed: ${ext}"
        else
            info "Installing VS Code extension: ${ext}..."
            ext_out=""
            if ! ext_out="$(run_vscode --install-extension "$ext" --force 2>&1)"; then
                info "Extension install failed for ${ext}: $(printf '%s' "$ext_out" | tail -n 3 | tr '\n' ' ')"
            fi
        fi
    done

    INSTALLED_EXTS="$(run_vscode --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
    for ext in "${REQUIRED_VSCODE_EXTS[@]}"; do
        ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
        if ! printf '%s\n' "$INSTALLED_EXTS" | grep -qx "$ext_lower"; then
            MISSING_VSCODE_EXTS+=("$ext")
        fi
    done

    if [ "${#MISSING_VSCODE_EXTS[@]}" -eq 0 ]; then
        ok "All required VS Code extensions verified (Python, Jupyter, Data Wrangler)."
    else
        info "Missing VS Code extension(s): ${MISSING_VSCODE_EXTS[*]}"
    fi
else
    info "VS Code was not detected or could not be installed automatically. This will be listed in the final action items."
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
    BASE_REPO_ROOT="${HOME}/Courses/${TARGET_DIR_NAME}"
    REPO_ROOT="${BASE_REPO_ROOT}"
    if [ -e "${REPO_ROOT}" ]; then
        _ver=2
        while [ -e "${BASE_REPO_ROOT}_v${_ver}" ]; do
            _ver=$((_ver + 1))
        done
        REPO_ROOT="${BASE_REPO_ROOT}_v${_ver}"
        info "Existing folder found at ${BASE_REPO_ROOT}; creating fresh session folder: ${REPO_ROOT}"
    fi

    if ! command -v git >/dev/null 2>&1 && [ -n "$PKG_MGR" ]; then
        info "Git not found; attempting to install git..."
        case "$PKG_MGR" in
            apt) apt_update_once && run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y git curl unzip || true ;;
            dnf) run_privileged dnf install -y git curl unzip || true ;;
            pacman) run_privileged pacman -Sy --noconfirm git curl unzip || true ;;
            zypper) run_privileged zypper --non-interactive install git curl unzip || true ;;
        esac
    fi

    if command -v git >/dev/null 2>&1; then
        info "Cloning student repository from ${REPO_URL} into ${REPO_ROOT}..."
        git clone "$REPO_URL" "$REPO_ROOT"
    else
        ensure_cmd curl curl curl curl curl || true
        ensure_cmd unzip unzip unzip unzip unzip || true
        if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
            err "Neither 'git' nor 'curl'+'unzip' are available to download the course repository."
            err "Please install 'git' (or 'curl' and 'unzip') and re-run."
            exit 1
        fi

        info "Git not available; downloading repository ZIP archive via curl..."
        ZIP_URL="${REPO_URL%.git}/archive/refs/heads/main.zip"
        TMP_ZIP="$(mktemp /tmp/ife_bi_repo_XXXXXX.zip)"
        TMP_EXTRACT="$(mktemp -d /tmp/ife_bi_extract_XXXXXX)"
        if ! curl -fSL "$ZIP_URL" -o "$TMP_ZIP" || ! unzip -q "$TMP_ZIP" -d "$TMP_EXTRACT"; then
            rm -rf "$TMP_ZIP" "$TMP_EXTRACT"
            err "Failed to download or extract course archive from ${ZIP_URL}."
            exit 1
        fi
        INNER_DIR="$(find "$TMP_EXTRACT" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
        mkdir -p "$REPO_ROOT"
        cp -R "${INNER_DIR}/." "$REPO_ROOT/"
        rm -rf "$TMP_ZIP" "$TMP_EXTRACT"
    fi

    # Carry forward upstream Parquet outputs from the most recent previous lab folder (if any)
    _new_sandbox="${REPO_ROOT}/03_labs_student_starters/sandbox_outputs"
    _prev_sandbox=""
    while IFS= read -r _cand_dir; do
        [ -z "$_cand_dir" ] && continue
        [ "$_cand_dir" = "$REPO_ROOT" ] && continue
        _cand_sb="${_cand_dir}/03_labs_student_starters/sandbox_outputs"
        if [ -d "$_cand_sb" ] && [ -n "$(find "$_cand_sb" -name '*.parquet' -print -quit 2>/dev/null)" ]; then
            _prev_sandbox="$_cand_sb"
            break
        fi
    done < <(ls -dt "${HOME}/Courses/ife_bi_bigdata_student"* "${HOME}/Documents/ife_bi_bigdata_student"* 2>/dev/null || true)

    if [ -n "$_prev_sandbox" ]; then
        info "Copying previous Parquet sandbox_outputs from ${_prev_sandbox}..."
        (cd "$_prev_sandbox" && find . -name '*.parquet' -print0 | while IFS= read -r -d '' _pq; do
            mkdir -p "${_new_sandbox}/$(dirname "$_pq")"
            cp "$_pq" "${_new_sandbox}/${_pq}"
        done)
        ok "Carried forward previous sandbox_outputs/*.parquet into new session folder."
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
    run_vscode "$REPO_ROOT" >/dev/null 2>&1 || true
fi

if [ -n "$CODE_CLI" ] && [ "${#MISSING_VSCODE_EXTS[@]}" -eq 0 ]; then
    step "SETUP COMPLETE!"
    echo "  Workspace folder : ${REPO_ROOT}"
    echo "  Python .venv     : ${VENV_PYTHON}"
    echo "  Open this folder in VS Code and select the 'Python (.venv - BI & Big Data)' kernel."
    echo ""
else
    step "SETUP PARTIALLY COMPLETE — ACTION REQUIRED"
    echo "  Workspace folder : ${REPO_ROOT}"
    echo "  Python .venv     : ${VENV_PYTHON}"
    echo ""
    echo "  Remaining step(s) to finish VS Code setup:"
    if [ -z "$CODE_CLI" ]; then
        if [ "$IS_WSL" -eq 1 ]; then
            echo "    1. Install Visual Studio Code on Windows: https://code.visualstudio.com/download"
            echo "    2. Install the 'WSL' extension (ms-vscode-remote.remote-wsl) on Windows VS Code."
            echo "    3. Inside WSL, open the workspace with: cd \"${REPO_ROOT}\" && code ."
        else
            echo "    1. Install Visual Studio Code: https://code.visualstudio.com/download"
            echo "    2. Install the required extensions in VS Code (or terminal):"
            for ext in "${REQUIRED_VSCODE_EXTS[@]}"; do
                echo "         code --install-extension ${ext}"
            done
        fi
    else
        echo "    1. Install the missing VS Code extension(s) via Extensions sidebar or terminal:"
        _code_disp="$CODE_CLI"
        [ "$CODE_IS_FLATPAK" -eq 1 ] && _code_disp="flatpak run com.visualstudio.code"
        for ext in "${MISSING_VSCODE_EXTS[@]}"; do
            echo "         ${_code_disp} --install-extension ${ext}"
        done
    fi
    echo ""
    echo "  Alternative (browser-based JupyterLab without VS Code):"
    echo "    \"${VENV_PYTHON}\" -m jupyterlab"
    echo ""
fi
