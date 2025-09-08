# Linux Toolkit

Linux 实用工具脚本集合，提供系统管理和开发环境配置的自动化解决方案。

## 架构设计

### 项目结构

```
linux-toolkit/
├── lib/
│   └── common.sh       # 统一函数库 (无代码重复)
├── zshconfig/          # Zsh 配置模块
│   ├── setup.sh        # 自动安装配置
│   └── uninstall.sh    # 清理卸载
├── system/             # 系统管理模块
│   ├── clean.sh        # 智能系统清理
│   └── info.sh         # 系统信息查看
├── network/            # 网络工具模块
│   └── speed.sh        # 网络性能测试
├── docker/             # Docker 管理模块
│   └── cleanup.sh      # 容器镜像清理
└── backup/             # 数据备份模块
    └── home.sh         # 个人文件备份
```

### 双模式执行架构

每个脚本都支持两种执行模式：

1. **本地执行**: 使用本地 `lib/common.sh`
2. **远程执行**: 自动下载 `common.sh` 到临时文件

此设计消除了代码重复，统一了日志输出、错误处理和公共工具函数。

## 快速开始

### 安装方式说明

所有脚本都设计为**无需 root 权限**运行：

- **自动依赖处理**: 脚本会检测必需的工具，提供清晰的安装指引
- **用户空间安装**: 工具安装到 `~/.local/bin`（如 zsh、speedtest-cli）
- **优雅降级**: 缺少系统权限时自动切换到用户可执行的操作
- **清晰提示**: 明确指出哪些操作需要手动安装系统包

### 一键执行脚本 (推荐)

脚本支持独立执行，自动下载依赖库：

```bash
# Zsh 配置 (自动下载 common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash

# 系统清理 (自动下载 common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash

# Docker 清理 (自动下载 common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# 网络测速 (自动下载 common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/network/speed.sh | bash
```

### 本地安装

```bash
git clone https://github.com/VocabVictor/linux-toolkit.git
cd linux-toolkit
make install  # 安装到 ~/bin
make test     # 运行测试
```

## 功能模块

### Zsh 环境配置 (zshconfig)

自动安装 Oh My Zsh + Powerlevel10k，完全无需 root 权限。自动处理依赖关系，提供清晰的手动安装指引。

**特性**: 框架安装、主题美化、语法高亮、智能补全、配置备份

```bash
# 本地执行
./zshconfig/setup.sh
./zshconfig/uninstall.sh
```

### 系统管理 (system)

**智能清理**: `clean.sh` - 无需 root 权限的安全清理，处理用户缓存、临时文件，并提示系统级清理命令
**系统信息**: `info.sh` - 显示系统配置和资源使用情况

### Docker 管理 (docker)

**全面清理**: `cleanup.sh` - 一键清理停止容器、无用镜像、卷、网络和构建缓存

### 网络工具 (network)

**速度测试**: `speed.sh` - 自动安装 speedtest-cli 到用户目录，检测上下行带宽和延迟

### 数据备份 (backup)

**个人备份**: `home.sh` - 智能备份配置文件、SSH 密钥、重要数据

## 配置选项

支持环境变量控制脚本行为：

```bash
# 静默模式 (非交互执行)
BATCH=true curl -fsSL <script_url> | bash

# CI 环境模式
CI=true curl -fsSL <script_url> | bash

# 自定义下载超时 (秒)
DOWNLOAD_TIMEOUT=60 curl -fsSL <script_url> | bash
```

## 系统支持

| 系统 | 状态 | 说明 |
|------|------|------|
| Ubuntu/Debian | ✅ 全支持 | 无需 root 权限，优雅降级处理 |
| CentOS/RHEL | ✅ 全支持 | 无需 root 权限，优雅降级处理 |
| Arch Linux | ✅ 全支持 | 无需 root 权限，优雅降级处理 |
| macOS | ⚠️ 部分支持 | 不支持系统清理功能 |

## 开发指南

```bash
make deps     # 安装开发依赖 (shellcheck)
make test     # 语法校验所有脚本
make lint     # shellcheck 代码质量检查
make install  # 安装到 ~/bin 目录
```

### 技术特性

- **无需 root 权限**: 所有脚本都能在普通用户权限下运行
- **智能依赖处理**: 自动检测依赖，提供清晰的手动安装指引
- **优雅降级**: 缺少系统权限时自动切换到用户空间操作
- **零依赖**: 远程执行无需安装，自动下载依赖
- **双模式**: 本地开发 + 远程一键部署
- **错误处理**: 统一的异常处理和日志输出
- **安全性**: 临时文件自动清理，`set -euo pipefail`
- **兼容性**: 支持 curl/wget，多发行版兼容

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交 Issue 和 Pull Request。

- Bug 报告: [GitHub Issues](https://github.com/VocabVictor/linux-toolkit/issues)
- 功能建议: 通过 Pull Request 提交