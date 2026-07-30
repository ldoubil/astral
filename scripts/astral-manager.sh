#!/usr/bin/env bash
# ============================================================================
# Astral Manager - 自动化安装、更新与管理脚本
# Repository: https://github.com/ldoubil/astral
# Description: 去中心化组网工具 Astral 的跨平台部署管理工具
# License: PolyForm Noncommercial License 1.0.0
# ============================================================================

set -euo pipefail

# ============================== 全局变量 ==============================
readonly REPO_OWNER="ldoubil"
readonly REPO_NAME="astral"
readonly REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
readonly REPO_API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"
readonly REPO_RELEASES="${REPO_API}/releases/latest"

readonly ASTRAL_DATA_DIR="${HOME}/.astral"
readonly ASTRAL_LOG_FILE="${ASTRAL_DATA_DIR}/astral-manager.log"
readonly ASTRAL_VERSION_FILE="${ASTRAL_DATA_DIR}/version"
readonly ASTRAL_REPO_DIR="${ASTRAL_DATA_DIR}/repo"

# 安装路径（Linux: /opt/astral, macOS: /Applications/Astral.app）
readonly LINUX_INSTALL_DIR="/opt/astral"
readonly MACOS_INSTALL_DIR="/Applications/Astral.app"

# systemd 服务文件路径
readonly SYSTEMD_SERVICE_NAME="astral-auto-update"
readonly SYSTEMD_SERVICE_DIR="/etc/systemd/system"
readonly SYSTEMD_SERVICE_FILE="${SYSTEMD_SERVICE_DIR}/${SYSTEMD_SERVICE_NAME}.service"
readonly SYSTEMD_TIMER_FILE="${SYSTEMD_SERVICE_DIR}/${SYSTEMD_SERVICE_NAME}.timer"

# 脚本自身路径（用于 systemd service 引用）
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

# 颜色定义
if [[ -t 1 ]]; then
    readonly COLOR_RED='\033[0;31m'
    readonly COLOR_GREEN='\033[0;32m'
    readonly COLOR_YELLOW='\033[1;33m'
    readonly COLOR_BLUE='\033[0;34m'
    readonly COLOR_CYAN='\033[0;36m'
    readonly COLOR_BOLD='\033[1m'
    readonly COLOR_RESET='\033[0m'
else
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_CYAN=''
    readonly COLOR_BOLD=''
    readonly COLOR_RESET=''
fi

# ============================== 日志函数 ==============================

log_init() {
    mkdir -p "${ASTRAL_DATA_DIR}"
    touch "${ASTRAL_LOG_FILE}"
}

log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${COLOR_CYAN}[${timestamp}]${COLOR_RESET} ${level} ${msg}" | tee -a "${ASTRAL_LOG_FILE}"
}

log_info()    { log "${COLOR_GREEN}[INFO]${COLOR_RESET}"    "$*"; }
log_warn()    { log "${COLOR_YELLOW}[WARN]${COLOR_RESET}"    "$*"; }
log_error()   { log "${COLOR_RED}[ERROR]${COLOR_RESET}"     "$*"; }
log_debug()   { log "${COLOR_BLUE}[DEBUG]${COLOR_RESET}"    "$*"; }

# ============================== 工具函数 ==============================

# 检测操作系统
detect_os() {
    local os_type
    os_type="$(uname -s)"
    case "${os_type}" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

# 检测 CPU 架构
detect_arch() {
    local arch
    arch="$(uname -m)"
    case "${arch}" in
        x86_64|amd64) echo "x64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             echo "${arch}" ;;
    esac
}

# 检测包管理器
detect_pkg_manager() {
    if command -v dpkg &>/dev/null; then
        echo "deb"
    elif command -v rpm &>/dev/null; then
        echo "rpm"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "tar"
    fi
}

# 检查命令是否存在
has_command() {
    command -v "$1" &>/dev/null
}

# 检查依赖命令
check_dependencies() {
    local missing=()
    local deps=("curl" "wget" "tar" "git")
    # curl 或 wget 至少需要一个
    if ! has_command curl && ! has_command wget; then
        missing+=("curl 或 wget")
    fi
    for dep in "tar" "git"; do
        if ! has_command "${dep}"; then
            missing+=("${dep}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "缺少依赖命令: ${missing[*]}"
        log_error "请先安装这些工具后重试。"
        case "$(detect_os)" in
            linux)
                log_info "Ubuntu/Debian: sudo apt install -y curl wget tar git"
                log_info "CentOS/RHEL:   sudo yum install -y curl wget tar git"
                ;;
            macos)
                log_info "macOS: xcode-select --install  或  brew install curl wget git"
                ;;
        esac
        return 1
    fi
}

# HTTP 下载（自动选择 curl 或 wget）
http_download() {
    local url="$1"
    local output="$2"

    if has_command curl; then
        curl -fSL --connect-timeout 30 --max-time 300 -o "${output}" "${url}" 2>&1 | tail -1
    elif has_command wget; then
        wget --timeout=30 --tries=3 -O "${output}" "${url}" 2>&1 | tail -1
    else
        log_error "未找到 curl 或 wget"
        return 1
    fi
}

# HTTP GET（获取文本内容，如 API 响应）
http_get() {
    local url="$1"
    if has_command curl; then
        curl -fsSL --connect-timeout 15 -H "Accept: application/vnd.github+json" "${url}" 2>/dev/null
    elif has_command wget; then
        wget -qO- --timeout=15 --header="Accept: application/vnd.github+json" "${url}" 2>/dev/null
    fi
}

# 获取 sudo 权限（如需要）
ensure_sudo() {
    if [[ "$(detect_os)" == "linux" ]] && [[ ! -w "${LINUX_INSTALL_DIR}" ]]; then
        if ! sudo -n true 2>/dev/null; then
            log_warn "需要 sudo 权限来安装到 ${LINUX_INSTALL_DIR}"
        fi
    fi
}

# 获取最新 release 版本号
get_latest_version() {
    local version
    version="$(http_get "${REPO_RELEASES}" 2>/dev/null | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"//;s/"//')"
    if [[ -z "${version}" ]]; then
        log_error "无法获取最新版本号，请检查网络连接"
        return 1
    fi
    # 去掉 v 前缀
    echo "${version#v}"
}

# 获取本地已安装版本
get_installed_version() {
    if [[ -f "${ASTRAL_VERSION_FILE}" ]]; then
        cat "${ASTRAL_VERSION_FILE}"
    else
        echo ""
    fi
}

# 比较版本号（返回 0=相等, 1=v1>v2, 2=v1<v2）
version_compare() {
    local v1="$1"
    local v2="$2"

    if [[ "$v1" == "$v2" ]]; then
        return 0
    fi

    local IFS=.
    local i v1_parts=($v1) v2_parts=($v2)

    for ((i = 0; i < ${#v1_parts[@]} || i < ${#v2_parts[@]}; i++)); do
        local n1="${v1_parts[i]:-0}"
        local n2="${v2_parts[i]:-0}"
        if ((n1 > n2)); then
            return 1
        elif ((n1 < n2)); then
            return 2
        fi
    done
    return 0
}

# 获取安装路径
get_install_dir() {
    local os
    os="$(detect_os)"
    if [[ "${os}" == "macos" ]]; then
        echo "${MACOS_INSTALL_DIR}"
    else
        echo "${LINUX_INSTALL_DIR}"
    fi
}

# ============================== 核心功能 ==============================

# --- 安装 ---
do_install() {
    log_info "开始安装 Astral..."
    check_dependencies || return 1

    local os arch pkg_manager latest_version install_dir
    os="$(detect_os)"
    arch="$(detect_arch)"
    pkg_manager="$(detect_pkg_manager)"
    latest_version="$(get_latest_version)" || return 1
    install_dir="$(get_install_dir)"

    log_info "操作系统: ${os}"
    log_info "架构: ${arch}"
    log_info "最新版本: v${latest_version}"
    log_info "安装路径: ${install_dir}"

    # macOS 平台检查
    if [[ "${os}" == "macos" ]]; then
        log_warn "macOS 平台暂无预编译 release 资产"
        log_info "请参考项目文档手动编译: ${REPO_URL}#-快速开始"
        log_info "或尝试从源码构建: ./astral-manager.sh build-from-source"
        return 1
    fi

    # 构建下载 URL
    local asset_name download_url tmp_dir
    case "${pkg_manager}" in
        deb)  asset_name="astral-linux-${arch}.deb" ;;
        rpm)  asset_name="astral-linux-${arch}.rpm" ;;
        tar)  asset_name="astral-linux-${arch}.tar.gz" ;;
        brew) asset_name="astral-linux-${arch}.tar.gz" ;;
    esac

    download_url="${REPO_URL}/releases/download/v${latest_version}/${asset_name}"
    tmp_dir="$(mktemp -d)"
    local downloaded_file="${tmp_dir}/${asset_name}"

    log_info "下载资产: ${asset_name}"
    log_debug "URL: ${download_url}"

    if ! http_download "${download_url}" "${downloaded_file}"; then
        log_error "下载失败: ${download_url}"
        rm -rf "${tmp_dir}"
        return 1
    fi

    if [[ ! -s "${downloaded_file}" ]]; then
        log_error "下载的文件为空或不存在"
        rm -rf "${tmp_dir}"
        return 1
    fi

    log_info "下载完成: $(du -h "${downloaded_file}" | cut -f1)"

    # 安装
    case "${pkg_manager}" in
        deb)
            log_info "通过 dpkg 安装..."
            sudo dpkg -i "${downloaded_file}" 2>&1 | tee -a "${ASTRAL_LOG_FILE}" || {
                log_error "dpkg 安装失败"
                rm -rf "${tmp_dir}"
                return 1
            }
            ;;
        rpm)
            log_info "通过 rpm 安装..."
            sudo rpm -Uvh --force "${downloaded_file}" 2>&1 | tee -a "${ASTRAL_LOG_FILE}" || {
                log_error "rpm 安装失败"
                rm -rf "${tmp_dir}"
                return 1
            }
            ;;
        tar|*)
            log_info "通过 tar.gz 解压安装..."
            if [[ "${os}" == "linux" ]]; then
                sudo mkdir -p "${install_dir}"
                sudo tar -xzf "${downloaded_file}" -C "${install_dir}" --strip-components=0 2>&1 | tee -a "${ASTRAL_LOG_FILE}"
                sudo chmod +x "${install_dir}/astral" 2>/dev/null || true
                # 设置库搜索路径
                echo "${install_dir}/lib" | sudo tee /etc/ld.so.conf.d/astral.conf >/dev/null
                sudo ldconfig 2>/dev/null || true
            fi
            ;;
    esac

    # 记录版本号
    echo "${latest_version}" > "${ASTRAL_VERSION_FILE}"

    # 清理临时文件
    rm -rf "${tmp_dir}"

    log_info "✓ Astral v${latest_version} 安装成功！"
    log_info "  安装路径: ${install_dir}"
    log_info "  版本记录: ${ASTRAL_VERSION_FILE}"

    # 提示后续配置
    echo ""
    log_info "后续操作建议："
    log_info "  1. 配置免密 sudo:  sudo bash ${SCRIPT_PATH} setup-sudoers"
    log_info "  2. 配置开机自启:  bash ${SCRIPT_PATH} enable-autostart"
    log_info "  3. 启用自动更新:  bash ${SCRIPT_PATH} enable-autoupdate"
    log_info "  4. 克隆仓库跟踪:  bash ${SCRIPT_PATH} track-repo"
}

# --- 更新 ---
do_update() {
    log_info "检查更新..."
    check_dependencies || return 1

    local current_version latest_version
    current_version="$(get_installed_version)"
    latest_version="$(get_latest_version)" || return 1

    if [[ -z "${current_version}" ]]; then
        log_warn "未检测到已安装版本，将执行全新安装"
        do_install
        return $?
    fi

    log_info "当前版本: v${current_version}"
    log_info "最新版本: v${latest_version}"

    version_compare "${current_version}" "${latest_version}"
    local cmp_result=$?

    case ${cmp_result} in
        0)
            log_info "✓ 已是最新版本，无需更新"
            return 0
            ;;
        1)
            log_warn "本地版本 (v${current_version}) 高于远程版本 (v${latest_version})，跳过更新"
            return 0
            ;;
        2)
            log_info "发现新版本: v${current_version} → v${latest_version}"
            ;;
    esac

    # 备份当前版本
    local install_dir backup_dir
    install_dir="$(get_install_dir)"
    if [[ -d "${install_dir}" ]]; then
        backup_dir="${ASTRAL_DATA_DIR}/backup-v${current_version}"
        log_info "备份当前版本到: ${backup_dir}"
        if [[ "$(detect_os)" == "linux" ]]; then
            sudo cp -r "${install_dir}" "${backup_dir}" 2>/dev/null || log_warn "备份失败，继续更新"
        else
            cp -r "${install_dir}" "${backup_dir}" 2>/dev/null || log_warn "备份失败，继续更新"
        fi
    fi

    # 停止正在运行的实例
    log_info "停止正在运行的 Astral 进程..."
    pkill -f "astral" 2>/dev/null || true
    sleep 1

    # 执行安装（覆盖更新）
    do_install

    local install_result=$?
    if [[ ${install_result} -eq 0 ]]; then
        log_info "✓ 更新成功: v${current_version} → v${latest_version}"
        # 清理超过 3 个的旧备份
        local backups=("${ASTRAL_DATA_DIR}/backup-v"*)
        if [[ ${#backups[@]} -gt 3 ]]; then
            log_info "清理旧版本备份..."
            ls -dt "${ASTRAL_DATA_DIR}/backup-v"* | tail -n +4 | while read -r old_backup; do
                rm -rf "${old_backup}" 2>/dev/null
            done
        fi
    else
        log_error "更新失败，尝试恢复备份..."
        if [[ -n "${backup_dir:-}" ]] && [[ -d "${backup_dir}" ]]; then
            if [[ "$(detect_os)" == "linux" ]]; then
                sudo rm -rf "${install_dir}"
                sudo cp -r "${backup_dir}" "${install_dir}"
            else
                rm -rf "${install_dir}"
                cp -r "${backup_dir}" "${install_dir}"
            fi
            log_warn "已恢复到 v${current_version}"
        fi
        return 1
    fi
}

# --- 检查更新 ---
do_check() {
    log_info "检查远程最新版本..."

    local current_version latest_version
    current_version="$(get_installed_version)"
    latest_version="$(get_latest_version)" || return 1

    if [[ -z "${current_version}" ]]; then
        echo -e "${COLOR_YELLOW}Astral 尚未安装${COLOR_RESET}"
        echo -e "最新版本: ${COLOR_GREEN}v${latest_version}${COLOR_RESET}"
        echo -e "运行 ${COLOR_BOLD}bash ${SCRIPT_PATH} install${COLOR_RESET} 进行安装"
        return 0
    fi

    echo -e "本地版本: ${COLOR_CYAN}v${current_version}${COLOR_RESET}"
    echo -e "远程版本: ${COLOR_CYAN}v${latest_version}${COLOR_RESET}"

    version_compare "${current_version}" "${latest_version}"
    local cmp_result=$?

    case ${cmp_result} in
        0)
            echo -e "${COLOR_GREEN}✓ 已是最新版本${COLOR_RESET}"
            ;;
        1)
            echo -e "${COLOR_YELLOW}⚠ 本地版本高于远程版本${COLOR_RESET}"
            ;;
        2)
            echo -e "${COLOR_YELLOW}⬆ 有新版本可用: v${current_version} → v${latest_version}${COLOR_RESET}"
            echo -e "运行 ${COLOR_BOLD}bash ${SCRIPT_PATH} update${COLOR_RESET} 进行更新"
            ;;
    esac
}

# --- 卸载 ---
do_uninstall() {
    log_info "开始卸载 Astral..."

    local install_dir os
    os="$(detect_os)"
    install_dir="$(get_install_dir)"

    # 停止进程
    log_info "停止 Astral 进程..."
    pkill -f "astral" 2>/dev/null || true

    # 移除安装目录
    if [[ -d "${install_dir}" ]]; then
        log_info "移除安装目录: ${install_dir}"
        if [[ "${os}" == "linux" ]]; then
            sudo rm -rf "${install_dir}"
            sudo rm -f /etc/ld.so.conf.d/astral.conf
            sudo ldconfig 2>/dev/null || true
        else
            rm -rf "${install_dir}"
        fi
    fi

    # 移除包管理器安装的包
    if [[ "${os}" == "linux" ]]; then
        if dpkg -l | grep -q "astral" 2>/dev/null; then
            log_info "通过 dpkg 移除包..."
            sudo dpkg -r astral 2>/dev/null || true
        elif rpm -q astral &>/dev/null; then
            log_info "通过 rpm 移除包..."
            sudo rpm -e astral 2>/dev/null || true
        fi
    fi

    # 禁用自动更新
    do_disable_autoupdate 2>/dev/null || true

    # 询问是否移除数据目录
    echo ""
    echo -e "${COLOR_YELLOW}是否移除用户数据目录 ${ASTRAL_DATA_DIR}?${COLOR_RESET}"
    echo -e "  (包含版本记录、日志、备份、仓库克隆)"
    read -rp "确认移除? [y/N]: " confirm
    if [[ "${confirm}" == "y" || "${confirm}" == "Y" ]]; then
        rm -rf "${ASTRAL_DATA_DIR}"
        log_info "用户数据目录已移除"
    else
        log_info "保留用户数据目录: ${ASTRAL_DATA_DIR}"
    fi

    # 移除 sudoers 配置
    if [[ "${os}" == "linux" ]] && [[ -f /etc/sudoers.d/astral ]]; then
        log_info "移除 sudoers 配置..."
        sudo rm -f /etc/sudoers.d/astral
    fi

    # 移除 autostart 配置
    if [[ -f "${HOME}/.config/autostart/astral.desktop" ]]; then
        rm -f "${HOME}/.config/autostart/astral.desktop"
        log_info "已移除开机自启配置"
    fi

    log_info "✓ Astral 卸载完成"
}

# --- 显示版本 ---
do_version() {
    local current_version latest_version
    current_version="$(get_installed_version)"

    if [[ -z "${current_version}" ]]; then
        echo -e "${COLOR_YELLOW}Astral 尚未安装${COLOR_RESET}"
    else
        local install_dir
        install_dir="$(get_install_dir)"
        echo -e "Astral v${COLOR_GREEN}${current_version}${COLOR_RESET}"
        echo -e "安装路径: ${install_dir}"
        if [[ -f "${install_dir}/astral" ]]; then
            echo -e "二进制文件: ${install_dir}/astral"
        fi
    fi
}

# --- 仓库跟踪 ---
do_track_repo() {
    log_info "配置仓库自动跟踪..."

    check_dependencies || return 1

    if ! has_command git; then
        log_error "git 未安装，请先安装 git"
        return 1
    fi

    # 克隆或更新仓库
    if [[ -d "${ASTRAL_REPO_DIR}/.git" ]]; then
        log_info "仓库已存在，更新中..."
        cd "${ASTRAL_REPO_DIR}"

        # 确保 remote 配置正确
        if ! git remote get-url origin &>/dev/null; then
            log_info "配置 remote origin..."
            git remote add origin "${REPO_URL}"
        else
            local current_remote
            current_remote="$(git remote get-url origin)"
            if [[ "${current_remote}" != "${REPO_URL}" ]] && [[ "${current_remote}" != "${REPO_URL}.git" ]]; then
                log_warn "remote origin URL 不匹配，修正中..."
                git remote set-url origin "${REPO_URL}"
            fi
        fi

        # 获取并合并最新代码
        log_info "获取远程更新..."
        git fetch origin 2>&1 | tee -a "${ASTRAL_LOG_FILE}"

        local current_branch
        current_branch="$(git branch --show-current 2>/dev/null || echo 'main')"

        # 确保跟踪 main 分支
        if [[ "${current_branch}" != "main" ]]; then
            log_info "切换到 main 分支..."
            git checkout main 2>/dev/null || git checkout -b main origin/main 2>/dev/null || true
        fi

        # 设置上游跟踪
        git branch --set-upstream-to=origin/main main 2>/dev/null || true

        log_info "合并远程更新..."
        git pull origin main 2>&1 | tee -a "${ASTRAL_LOG_FILE}" || {
            log_warn "自动合并失败，可能存在本地修改冲突"
            log_info "请手动进入 ${ASTRAL_REPO_DIR} 解决冲突"
        }

        log_info "✓ 仓库已更新到最新"
    else
        log_info "克隆仓库: ${REPO_URL}"
        rm -rf "${ASTRAL_REPO_DIR}"
        git clone --branch main "${REPO_URL}" "${ASTRAL_REPO_DIR}" 2>&1 | tee -a "${ASTRAL_LOG_FILE}" || {
            log_error "仓库克隆失败"
            return 1
        }

        cd "${ASTRAL_REPO_DIR}"
        git branch --set-upstream-to=origin/main main 2>/dev/null || true

        log_info "✓ 仓库已克隆到: ${ASTRAL_REPO_DIR}"
    fi

    # 显示仓库状态
    echo ""
    log_info "仓库状态:"
    cd "${ASTRAL_REPO_DIR}"
    echo "  路径:   ${ASTRAL_REPO_DIR}"
    echo "  远程:   $(git remote get-url origin)"
    echo "  分支:   $(git branch --show-current)"
    echo "  最新提交: $(git log --oneline -1)"
    echo "  本地修改: $(git status --porcelain | wc -l | tr -d ' ') 个文件"
}

# --- 配置 sudoers ---
do_setup_sudoers() {
    log_info "配置免密 sudo..."

    local os
    os="$(detect_os)"
    if [[ "${os}" != "linux" ]]; then
        log_warn "sudoers 配置仅适用于 Linux，跳过"
        return 0
    fi

    local install_dir current_user
    install_dir="$(get_install_dir)"
    current_user="$(whoami)"

    local sudoers_file="/etc/sudoers.d/astral"
    local sudoers_content="${current_user} ALL=(ALL) NOPASSWD: ${install_dir}/astral"

    echo "${sudoers_content}" | sudo tee "${sudoers_file}" >/dev/null
    sudo chmod 440 "${sudoers_file}"

    # 验证语法
    if sudo visudo -cf "${sudoers_file}" 2>/dev/null; then
        log_info "✓ sudoers 配置成功: ${sudoers_content}"
    else
        log_error "sudoers 语法验证失败，正在回滚..."
        sudo rm -f "${sudoers_file}"
        return 1
    fi
}

# --- 配置开机自启 ---
do_enable_autostart() {
    log_info "配置开机自启..."

    local os install_dir current_user user_uid
    os="$(detect_os)"
    install_dir="$(get_install_dir)"
    current_user="$(whoami)"
    user_uid="$(id -u)"

    if [[ "${os}" == "linux" ]]; then
        # 创建启动包装脚本
        local launch_script="${HOME}/.local/bin/astral-launch.sh"
        mkdir -p "$(dirname "${launch_script}")"

        cat > "${launch_script}" << 'LAUNCH_EOF'
#!/bin/bash
# Astral launcher - Wayland/X11 display environment for sudo execution
USER_UID=$(id -u)
export XDG_RUNTIME_DIR="/run/user/${USER_UID}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_UID}/bus"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"

if [ -z "$XAUTHORITY" ]; then
    if [ -f "/run/user/${USER_UID}/gdm/Xauthority" ]; then
        export XAUTHORITY="/run/user/${USER_UID}/gdm/Xauthority"
    elif [ -f "$HOME/.Xauthority" ]; then
        export XAUTHORITY="$HOME/.Xauthority"
    fi
fi

if command -v xhost &>/dev/null; then
    xhost +local:root 2>/dev/null
fi

exec sudo -E INSTALL_DIR_PLACEHOLDER/astral "$@"
LAUNCH_EOF

        # 替换占位符为实际安装路径
        sed -i "s|INSTALL_DIR_PLACEHOLDER|${install_dir}|g" "${launch_script}"
        chmod +x "${launch_script}"
        log_info "✓ 启动脚本: ${launch_script}"

        # 创建 autostart .desktop 文件
        local autostart_dir="${HOME}/.config/autostart"
        mkdir -p "${autostart_dir}"

        cat > "${autostart_dir}/astral.desktop" << DESKTOP_EOF
[Desktop Entry]
Type=Application
Name=Astral
GenericName=Astral P2P Network
Comment=Decentralized networking tool
Exec=${launch_script}
Icon=${install_dir}/data/flutter_assets/assets/logo.png
Terminal=false
Categories=Network;
X-GNOME-Autostart-enabled=true
StartupNotify=false
X-GNOME-Autostart-Delay=5
DESKTOP_EOF

        log_info "✓ 开机自启: ${autostart_dir}/astral.desktop"

        # 创建应用菜单项
        local app_dir="${HOME}/.local/share/applications"
        mkdir -p "${app_dir}"

        cat > "${app_dir}/astral.desktop" << APP_EOF
[Desktop Entry]
Type=Application
Name=Astral
GenericName=Astral P2P Network
Comment=Decentralized networking tool
Exec=${launch_script}
Icon=${install_dir}/data/flutter_assets/assets/logo.png
Terminal=false
Categories=Network;
StartupNotify=true
APP_EOF

        log_info "✓ 应用菜单: ${app_dir}/astral.desktop"

    elif [[ "${os}" == "macos" ]]; then
        # macOS LaunchAgent
        local plist_dir="${HOME}/Library/LaunchAgents"
        mkdir -p "${plist_dir}"

        cat > "${plist_dir}/com.astral.autostart.plist" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.astral.autostart</string>
    <key>ProgramArguments</key>
    <array>
        <string>${install_dir}/Contents/MacOS/astral</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
PLIST_EOF

        log_info "✓ LaunchAgent: ${plist_dir}/com.astral.autostart.plist"
    fi

    log_info "✓ 开机自启配置完成"
}

# --- 禁用开机自启 ---
do_disable_autostart() {
    log_info "移除开机自启配置..."

    rm -f "${HOME}/.config/autostart/astral.desktop" 2>/dev/null
    rm -f "${HOME}/.local/share/applications/astral.desktop" 2>/dev/null
    rm -f "${HOME}/Library/LaunchAgents/com.astral.autostart.plist" 2>/dev/null

    log_info "✓ 开机自启已禁用"
}

# --- 启用自动更新 ---
do_enable_autoupdate() {
    log_info "配置自动更新服务..."

    local os
    os="$(detect_os)"

    if [[ "${os}" == "linux" ]]; then
        # 检查 systemd
        if ! has_command systemctl; then
            log_error "systemd 不可用，请使用 cron 代替"
            log_info "示例: echo '0 3 * * * ${SCRIPT_PATH} update >> ${ASTRAL_LOG_FILE} 2>&1' | crontab -"
            return 1
        fi

        # 创建 systemd service
        local service_content="[Unit]
Description=Astral Auto Update Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH} update
User=${USER}
StandardOutput=append:${ASTRAL_LOG_FILE}
StandardError=append:${ASTRAL_LOG_FILE}"

        echo "${service_content}" | sudo tee "${SYSTEMD_SERVICE_FILE}" >/dev/null

        # 创建 systemd timer（每天凌晨 3 点执行）
        local timer_content="[Unit]
Description=Astral Daily Auto Update Timer

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target"

        echo "${timer_content}" | sudo tee "${SYSTEMD_TIMER_FILE}" >/dev/null

        # 启用 timer
        sudo systemctl daemon-reload
        sudo systemctl enable --now "${SYSTEMD_SERVICE_NAME}.timer"

        log_info "✓ 自动更新服务已启用"
        log_info "  Service: ${SYSTEMD_SERVICE_FILE}"
        log_info "  Timer:   ${SYSTEMD_TIMER_FILE}"
        log_info "  计划:    每天 03:00 ± 5分钟"
        echo ""
        log_info "查看定时器状态: systemctl status ${SYSTEMD_SERVICE_NAME}.timer"
        log_info "手动触发更新:   sudo systemctl start ${SYSTEMD_SERVICE_NAME}.service"

    elif [[ "${os}" == "macos" ]]; then
        # macOS LaunchAgent for auto-update
        local plist_dir="${HOME}/Library/LaunchAgents"
        mkdir -p "${plist_dir}"
        local plist_file="${plist_dir}/com.astral.autoupdate.plist"

        cat > "${plist_file}" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.astral.autoupdate</string>
    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_PATH}</string>
        <string>update</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>${ASTRAL_LOG_FILE}</string>
    <key>StandardErrorPath</key>
    <string>${ASTRAL_LOG_FILE}</string>
</dict>
</plist>
PLIST_EOF

        launchctl load "${plist_file}" 2>/dev/null || true
        log_info "✓ 自动更新已启用 (macOS LaunchAgent)"
        log_info "  配置: ${plist_file}"
        log_info "  计划: 每天 03:00"

    else
        # 通用 cron 方案
        log_info "使用 cron 配置自动更新..."
        local cron_entry="0 3 * * * ${SCRIPT_PATH} update >> ${ASTRAL_LOG_FILE} 2>&1"

        (crontab -l 2>/dev/null | grep -v "astral-manager.sh"; echo "${cron_entry}") | crontab -
        log_info "✓ cron 任务已添加: 每天 03:00"
    fi
}

# --- 禁用自动更新 ---
do_disable_autoupdate() {
    log_info "禁用自动更新服务..."

    local os
    os="$(detect_os)"

    if [[ "${os}" == "linux" ]] && has_command systemctl; then
        sudo systemctl disable --now "${SYSTEMD_SERVICE_NAME}.timer" 2>/dev/null || true
        sudo rm -f "${SYSTEMD_SERVICE_FILE}" "${SYSTEMD_TIMER_FILE}"
        sudo systemctl daemon-reload 2>/dev/null || true
        log_info "✓ systemd timer 已移除"
    elif [[ "${os}" == "macos" ]]; then
        local plist_file="${HOME}/Library/LaunchAgents/com.astral.autoupdate.plist"
        launchctl unload "${plist_file}" 2>/dev/null || true
        rm -f "${plist_file}"
        log_info "✓ LaunchAgent 已移除"
    else
        crontab -l 2>/dev/null | grep -v "astral-manager.sh" | crontab - 2>/dev/null || true
        log_info "✓ cron 任务已移除"
    fi
}

# --- 显示状态 ---
do_status() {
    local os arch install_dir current_version
    os="$(detect_os)"
    arch="$(detect_arch)"
    install_dir="$(get_install_dir)"
    current_version="$(get_installed_version)"

    echo -e "${COLOR_BOLD}========== Astral 状态 ==========${COLOR_RESET}"
    echo -e "操作系统:     ${os}"
    echo -e "架构:         ${arch}"
    echo -e "安装路径:     ${install_dir}"
    echo -e "已装版本:     ${current_version:-未安装}"
    echo -e "数据目录:     ${ASTRAL_DATA_DIR}"
    echo -e "日志文件:     ${ASTRAL_LOG_FILE}"
    echo -e "仓库克隆:     $([[ -d "${ASTRAL_REPO_DIR}/.git" ]] && echo '已克隆' || echo '未克隆')"

    echo ""
    echo -e "${COLOR_BOLD}========== 配置状态 ==========${COLOR_RESET}"

    # sudoers
    if [[ "${os}" == "linux" ]] && [[ -f /etc/sudoers.d/astral ]]; then
        echo -e "免密 sudo:    ${COLOR_GREEN}✓ 已配置${COLOR_RESET}"
    else
        echo -e "免密 sudo:    ${COLOR_RED}✗ 未配置${COLOR_RESET}"
    fi

    # autostart
    if [[ -f "${HOME}/.config/autostart/astral.desktop" ]] || [[ -f "${HOME}/Library/LaunchAgents/com.astral.autostart.plist" ]]; then
        echo -e "开机自启:     ${COLOR_GREEN}✓ 已配置${COLOR_RESET}"
    else
        echo -e "开机自启:     ${COLOR_RED}✗ 未配置${COLOR_RESET}"
    fi

    # auto-update
    if [[ "${os}" == "linux" ]] && has_command systemctl; then
        if systemctl is-enabled "${SYSTEMD_SERVICE_NAME}.timer" &>/dev/null; then
            local next_run
            next_run="$(systemctl list-timers "${SYSTEMD_SERVICE_NAME}.timer" --no-legend 2>/dev/null | awk '{print $7" "$8" "$9}' | head -1)"
            echo -e "自动更新:     ${COLOR_GREEN}✓ 已启用${COLOR_RESET} (下次: ${next_run:-未知})"
        else
            echo -e "自动更新:     ${COLOR_RED}✗ 未启用${COLOR_RESET}"
        fi
    elif [[ -f "${HOME}/Library/LaunchAgents/com.astral.autoupdate.plist" ]]; then
        echo -e "自动更新:     ${COLOR_GREEN}✓ 已启用${COLOR_RESET}"
    else
        echo -e "自动更新:     ${COLOR_RED}✗ 未启用${COLOR_RESET}"
    fi

    # 运行状态
    echo ""
    echo -e "${COLOR_BOLD}========== 运行状态 ==========${COLOR_RESET}"
    if pgrep -f "astral" &>/dev/null; then
        echo -e "进程状态:     ${COLOR_GREEN}运行中${COLOR_RESET}"
        pgrep -fa "astral" | head -5
    else
        echo -e "进程状态:     ${COLOR_YELLOW}未运行${COLOR_RESET}"
    fi
}

# ============================== 帮助信息 ==============================

show_help() {
    cat << 'HELP'
Astral Manager - 自动化安装、更新与管理脚本
仓库: https://github.com/ldoubil/astral

用法:
  astral-manager.sh <命令> [选项]

命令:
  install              安装 Astral（从 GitHub Release 下载最新版本）
  update               检查并更新到最新版本（含备份与回滚）
  check                仅检查是否有新版本可用
  uninstall            卸载 Astral（含清理配置）
  version              显示已安装的版本信息
  status               显示完整状态（安装、配置、运行状态）
  track-repo           克隆/更新仓库源码，配置 git 跟踪
  setup-sudoers        配置免密 sudo（仅 Linux）
  enable-autostart     配置开机自启动（Linux: .desktop / macOS: LaunchAgent）
  disable-autostart    禁用开机自启动
  enable-autoupdate    启用自动更新（Linux: systemd timer / macOS: LaunchAgent）
  disable-autoupdate   禁用自动更新
  help                 显示此帮助信息

示例:
  # 全新安装
  bash astral-manager.sh install

  # 安装并配置全部功能
  bash astral-manager.sh install && \
  bash astral-manager.sh setup-sudoers && \
  bash astral-manager.sh enable-autostart && \
  bash astral-manager.sh enable-autoupdate && \
  bash astral-manager.sh track-repo

  # 检查更新
  bash astral-manager.sh check

  # 手动更新
  bash astral-manager.sh update

日志:
  所有操作日志记录于 ~/.astral/astral-manager.log

跨平台支持:
  - Linux (x64/arm64): deb / rpm / tar.gz
  - macOS (x64/arm64): LaunchAgent (release 资产可用时自动下载)
HELP
}

# ============================== 主入口 ==============================

main() {
    local command="${1:-help}"
    shift || true

    log_init

    case "${command}" in
        install)              do_install "$@" ;;
        update)               do_update "$@" ;;
        check)                do_check "$@" ;;
        uninstall|remove)     do_uninstall "$@" ;;
        version|--version|-v) do_version "$@" ;;
        status)               do_status "$@" ;;
        track-repo|track)     do_track_repo "$@" ;;
        setup-sudoers)        do_setup_sudoers "$@" ;;
        enable-autostart)     do_enable_autostart "$@" ;;
        disable-autostart)    do_disable_autostart "$@" ;;
        enable-autoupdate)    do_enable_autoupdate "$@" ;;
        disable-autoupdate)   do_disable_autoupdate "$@" ;;
        help|--help|-h)       show_help ;;
        *)
            echo -e "${COLOR_RED}未知命令: ${command}${COLOR_RESET}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
