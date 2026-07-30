# Astral Manager - 自动化安装与更新脚本

> 用于在 Linux / macOS 终端上快速部署、更新和管理 [Astral](https://github.com/ldoubil/astral) 去中心化组网工具。

## 功能概览

| 功能 | 说明 |
|------|------|
| 自动安装 | 检测系统架构，从 GitHub Release 下载最新预编译包并安装 |
| 自动更新 | 对比本地与远程版本，自动下载、备份、更新、回滚 |
| 仓库跟踪 | 克隆 GitHub 仓库源码，配置 remote/branch 自动同步 |
| 开机自启 | Linux: GNOME/KDE `.desktop` autostart / macOS: LaunchAgent |
| 免密 sudo | 自动配置 sudoers，仅授权 astral 二进制免密运行 |
| 定时更新 | Linux: systemd timer / macOS: LaunchAgent / 通用: cron |
| 错误处理 | 完整日志记录，安装/更新失败时自动回滚 |
| 跨平台 | 兼容 Linux (x64/arm64) 和 macOS (x64/arm64) |

## 快速开始

### 一键安装（推荐）

```bash
# 克隆仓库
git clone https://github.com/ldoubil/astral.git
cd astral/scripts

# 赋予执行权限
chmod +x astral-manager.sh

# 全量配置（安装 + 免密sudo + 开机自启 + 自动更新 + 仓库跟踪）
bash astral-manager.sh install && \
bash astral-manager.sh setup-sudoers && \
bash astral-manager.sh enable-autostart && \
bash astral-manager.sh enable-autoupdate && \
bash astral-manager.sh track-repo
```

### 仅安装

```bash
bash astral-manager.sh install
```

### 检查更新

```bash
bash astral-manager.sh check
```

### 手动更新

```bash
bash astral-manager.sh update
```

## 命令一览

```
命令                   说明
─────────────────────────────────────────────────────────
install                安装 Astral（从 GitHub Release 下载最新版）
update                 检查并更新到最新版（含备份与回滚）
check                  仅检查是否有新版本
uninstall              卸载 Astral（含清理配置）
version                显示已安装版本
status                 显示完整状态
track-repo             克隆/更新仓库源码，配置 git 跟踪
setup-sudoers          配置免密 sudo（仅 Linux）
enable-autostart       配置开机自启动
disable-autostart      禁用开机自启动
enable-autoupdate      启用定时自动更新
disable-autoupdate     禁用定时自动更新
help                   显示帮助信息
```

## 使用示例

### 场景 1：新机器部署

```bash
# 1. 安装 Astral
bash astral-manager.sh install

# 2. 配置免密 sudo（避免每次启动输密码）
bash astral-manager.sh setup-sudoers

# 3. 配置开机自启
bash astral-manager.sh enable-autostart

# 4. 启用每天自动检查更新
bash astral-manager.sh enable-autoupdate

# 5. 克隆仓库源码用于跟踪
bash astral-manager.sh track-repo

# 6. 查看完整状态
bash astral-manager.sh status
```

### 场景 2：仅检查和手动更新

```bash
# 检查是否有新版本
bash astral-manager.sh check
# 输出示例:
# 本地版本: v2.9.8
# 远程版本: v2.9.9
# ⬆ 有新版本可用: v2.9.8 → v2.9.9

# 执行更新
bash astral-manager.sh update
# 自动备份当前版本 → 下载新版本 → 安装 → 验证
```

### 场景 3：卸载

```bash
bash astral-manager.sh uninstall
# 停止进程 → 移除安装目录 → 清理包管理器记录
# → 禁用自动更新 → 询问是否移除数据目录 → 移除 sudoers
```

## 文件说明

### 脚本文件

| 文件 | 说明 |
|------|------|
| `scripts/astral-manager.sh` | 主管理脚本（所有功能的入口） |
| `scripts/astral-auto-update.service` | systemd 服务文件模板 |
| `scripts/astral-auto-update.timer` | systemd 定时器文件模板 |

### 运行时文件

| 路径 | 说明 |
|------|------|
| `/opt/astral/` | Linux 安装目录 |
| `/Applications/Astral.app/` | macOS 安装目录 |
| `~/.astral/` | 用户数据目录 |
| `~/.astral/version` | 已安装版本号 |
| `~/.astral/astral-manager.log` | 操作日志 |
| `~/.astral/repo/` | 仓库源码克隆 |
| `~/.astral/backup-v*` | 旧版本备份 |
| `/etc/sudoers.d/astral` | 免密 sudo 配置（仅 Linux） |
| `~/.config/autostart/astral.desktop` | 开机自启配置（Linux GNOME） |
| `~/.local/bin/astral-launch.sh` | 启动包装脚本（处理 Wayland 显示） |

## 自动更新机制

### Linux (systemd timer)

- **计划**: 每天凌晨 03:00 ± 5 分钟随机延迟
- **行为**: 检查远程最新版本 → 有更新则自动下载安装 → 无更新则跳过
- **日志**: 写入 `~/.astral/astral-manager.log`

```bash
# 查看定时器状态
systemctl status astral-auto-update.timer

# 查看下次执行时间
systemctl list-timers astral-auto-update.timer

# 手动触发一次更新
sudo systemctl start astral-auto-update.service

# 查看更新日志
tail -f ~/.astral/astral-manager.log
```

### macOS (LaunchAgent)

- **计划**: 每天凌晨 03:00
- **配置**: `~/Library/LaunchAgents/com.astral.autoupdate.plist`

### 通用 (cron)

```bash
# 查看 cron 任务
crontab -l | grep astral

# 手动添加（如果 enable-autoupdate 未自动配置）
echo "0 3 * * * /path/to/astral-manager.sh update >> ~/.astral/astral-manager.log 2>&1" | crontab -
```

## 错误处理与日志

所有操作均记录到 `~/.astral/astral-manager.log`，包含时间戳和操作级别。

```bash
# 查看最近 50 行日志
tail -50 ~/.astral/astral-manager.log

# 实时跟踪日志
tail -f ~/.astral/astral-manager.log

# 搜索错误信息
grep "\[ERROR\]" ~/.astral/astral-manager.log
```

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| 下载失败 | 检查网络连接，确认能访问 github.com |
| 权限不足 | 使用 `sudo` 运行 install，或先运行 `setup-sudoers` |
| macOS 无 release | macOS 暂无预编译包，请参考项目文档从源码构建 |
| 更新后无法启动 | 运行 `status` 检查，或从 `~/.astral/backup-v*` 恢复 |
| Wayland 显示问题 | 确认 `astral-launch.sh` 中 DISPLAY 和 WAYLAND_DISPLAY 设置正确 |

## 跨平台兼容性

| 平台 | 架构 | 安装方式 | 自启动 | 自动更新 |
|------|------|----------|--------|----------|
| Linux (Debian/Ubuntu) | x64, arm64 | .deb | .desktop autostart | systemd timer |
| Linux (RHEL/CentOS) | x64, arm64 | .rpm | .desktop autostart | systemd timer |
| Linux (其他) | x64, arm64 | .tar.gz | .desktop autostart | systemd timer / cron |
| macOS | x64, arm64 | tar.gz (待 release) | LaunchAgent | LaunchAgent |

## 依赖项

- `curl` 或 `wget`（HTTP 下载）
- `tar`（解压）
- `git`（仓库跟踪）
- `sudo`（Linux 安装到 /opt）
- `systemctl`（Linux 自动更新，可选）

## 许可

本脚本遵循 [Astral 项目的 PolyForm Noncommercial License 1.0.0](https://github.com/ldoubil/astral/blob/main/LICENSE)。
