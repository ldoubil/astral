<div align="center">
  <img width="300" src="https://astral.fan/_astro/%E6%9A%97%E8%89%B2.C9IdEQgX.svg" alt="Astral Logo">
  <h1 id="astral"></h1>

  ![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-lightgrey.svg)
  ![Platforms](https://img.shields.io/badge/平台-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-blue?style=flat-square)
  ![Languages](https://img.shields.io/badge/多语言支持-中文%7C英文%7C德文%7C西班牙文%7C法文%7C日文%7C韩文%7C俄文-orange?style=flat-square)
  ![Fork](https://img.shields.io/badge/Fork-含自动化部署脚本-success?style=flat-square)
</div>

> **📌 本仓库是 [ldoubil/astral](https://github.com/ldoubil/astral) 的 Fork，新增了 `astral-manager.sh` 自动化部署管理脚本。**
> 相关改动已提交 PR：[ldoubil/astral#251](https://github.com/ldoubil/astral/pull/251)

Astral 是一个基于 EasyTier 的跨平台网络应用，提供简单易用的 P2P 网络连接。通过 Flutter 构建的现代化界面，让用户能够轻松创建和管理虚拟网络。

---

## 🚀 快速开始（自动化安装 - 推荐）

本仓库新增了 `astral-manager.sh` 脚本，支持在 Linux / macOS 上一键安装、更新、配置免密 sudo、开机自启和定时自动更新。

```bash
# 克隆本仓库
git clone https://github.com/liaozip/astral.git
cd astral/scripts
chmod +x astral-manager.sh

# 一键全量配置（安装 + 免密sudo + 开机自启 + 自动更新 + 仓库跟踪）
bash astral-manager.sh install && \
bash astral-manager.sh setup-sudoers && \
bash astral-manager.sh enable-autostart && \
bash astral-manager.sh enable-autoupdate && \
bash astral-manager.sh track-repo
```

<details>
<summary>📖 更多命令</summary>

| 命令 | 说明 |
|------|------|
| `bash astral-manager.sh install` | 安装最新版本（从 GitHub Release 下载） |
| `bash astral-manager.sh update` | 检查并更新到最新版（含备份与回滚） |
| `bash astral-manager.sh check` | 仅检查是否有新版本 |
| `bash astral-manager.sh uninstall` | 卸载 Astral（含清理配置） |
| `bash astral-manager.sh status` | 显示完整状态（安装、配置、运行） |
| `bash astral-manager.sh track-repo` | 克隆仓库源码并配置 git 跟踪 |
| `bash astral-manager.sh setup-sudoers` | 配置免密 sudo（仅 Linux） |
| `bash astral-manager.sh enable-autostart` | 配置开机自启动 |
| `bash astral-manager.sh enable-autoupdate` | 启用定时自动更新（systemd timer / cron） |
| `bash astral-manager.sh disable-autostart` | 禁用开机自启动 |
| `bash astral-manager.sh disable-autoupdate` | 禁用定时自动更新 |

完整文档请参考 [ASTRAL_MANAGER_README.md](ASTRAL_MANAGER_README.md)

</details>

<details>
<summary>🔧 astral-manager 功能特性</summary>

- **自动安装** — 检测 OS/架构，从 GitHub Release 下载 deb/rpm/tar.gz 包并安装
- **自动更新** — 版本号对比，更新前自动备份，安装失败自动回滚
- **仓库跟踪** — 克隆仓库到 `~/.astral/repo/`，配置 remote/branch 自动同步
- **免密 sudo** — 自动配置 sudoers，仅授权 astral 二进制免密运行
- **开机自启** — Linux: `.desktop` autostart / macOS: LaunchAgent
- **定时更新** — systemd timer（每天 03:00）/ cron / LaunchAgent
- **错误处理** — 完整日志记录（时间戳 + 级别），写入 `~/.astral/astral-manager.log`
- **跨平台** — Linux (x64/arm64) + macOS (x64/arm64)

</details>

---

## ✨ Astral 主要特性

- 🌐 **P2P 网络连接** - 基于 EasyTier 的去中心化网络架构
- 🔒 **VPN 服务** - 安全的虚拟专用网络连接
- 🖥️ **跨平台支持** - 全面支持多种操作系统和设备
  - 💻 **桌面平台**: Windows、macOS、Linux
  - 📱 **移动平台**: Android、iOS
- 🌍 **多语言支持** - 提供多种语言界面
- 🎨 **现代化界面** - 基于 Flutter 的美观用户界面
- ⚡ **高性能** - Rust 后端确保高效的网络处理
- 🔧 **易于配置** - 简单的房间和服务器管理

## 🛠️ 技术栈

- **前端**: Flutter (Dart)
- **后端**: Rust (EasyTier)
- **网络**: P2P、WireGuard

## 📦 功能说明

- **房间管理** - 创建和加入网络房间
- **服务器配置** - 配置和管理网络服务器
- **用户管理** - 查看和管理网络用户
- **网络设置** - 自定义网络参数和配置

## 🌍 多语言支持

| 语言 | 语言代码 | 文件 |
|------|---------|------|
| 🇨🇳 简体中文 | zh | [zh.json](assets/translations/zh.json) |
| 🇺🇸 英语 | en | [en.json](assets/translations/en.json) |

## 📄 许可协议

本软件采用 [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0) 进行许可。

### 使用限制说明
⚠️ 本软件仅供学习和非商业用途使用，使用时需遵守以下条款：
- ❌ **禁止商业使用** - 不得将本软件用于任何商业目的
- ❌ **禁止修改软件名称** - 不得更改 "Astral" 软件名称以混淆身份或进行二次售卖
- ✅ **保留版权声明** - 分发时必须保留 `LICENSE` 中的 Required Notice 及许可全文
- ✅ **遵循许可协议** - 严格遵守上述许可协议的全部条款

## 🙏 鸣谢

- **原项目**：[ldoubil/astral](https://github.com/ldoubil/astral) - 感谢原作者的开源贡献
- **浪浪云** - 提供云服务器赞助

## 📎 相关链接

- **原仓库**：[https://github.com/ldoubil/astral](https://github.com/ldoubil/astral)
- **本 Fork**：[https://github.com/liaozip/astral](https://github.com/liaozip/astral)
- **PR**：[ldoubil/astral#251](https://github.com/ldoubil/astral/pull/251)
- **自动化脚本文档**：[ASTRAL_MANAGER_README.md](ASTRAL_MANAGER_README.md)
- **项目文档**：[astral.fan](https://astral.fan)
