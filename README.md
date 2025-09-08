# Linux Toolkit

Linux 实用工具脚本集合，提供系统管理和开发环境配置的自动化解决方案。

## 项目结构

```
linux-toolkit/
├── lib/                # 公共函数库
├── zshconfig/          # Zsh 配置工具
│   ├── setup.sh        # 安装脚本
│   └── uninstall.sh    # 卸载脚本  
├── system/             # 系统管理工具
│   ├── clean.sh        # 系统清理
│   └── info.sh         # 系统信息
├── network/            # 网络工具
│   └── speed.sh        # 网络测试
├── docker/             # Docker 管理
│   └── cleanup.sh      # Docker 清理
└── backup/             # 备份工具
    └── home.sh         # 家目录备份
```

## 快速开始

### 一键安装脚本

```bash
# Zsh 配置
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash

# 系统清理
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash

# Docker 清理
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash
```

### 本地安装

```bash
git clone https://github.com/VocabVictor/linux-toolkit.git
cd linux-toolkit
make install  # 安装到 ~/bin
make test     # 运行测试
```

## 功能模块

### Zsh 配置 (zshconfig)

自动安装和配置 Oh My Zsh + Powerlevel10k 主题。

**功能:**
- Oh My Zsh 框架安装
- Powerlevel10k 主题配置
- 常用插件启用 (语法高亮、自动补全)
- 配置文件自动备份

**使用:**
```bash
./zshconfig/setup.sh     # 安装
./zshconfig/uninstall.sh # 卸载
```

### 系统管理 (system)

系统清理和信息查看工具。

**包含脚本:**
- `clean.sh` - 清理包缓存、临时文件、日志文件
- `info.sh` - 显示系统基本信息

### Docker 管理 (docker)

Docker 容器和镜像清理工具。

**包含脚本:**
- `cleanup.sh` - 清理停止的容器、未使用的镜像和卷

### 网络工具 (network)

网络测试和诊断工具。

**包含脚本:**
- `speed.sh` - 网络速度测试

### 备份工具 (backup)

数据备份和恢复脚本。

**包含脚本:**
- `home.sh` - 家目录重要文件备份

## 环境变量

```bash
# 禁用 GitHub 代理
GITHUB_PROXY=false curl -fsSL <script_url> | bash

# 静默模式
BATCH=true curl -fsSL <script_url> | bash
```

## 支持的系统

- Ubuntu/Debian
- CentOS/RHEL  
- Arch Linux
- macOS (部分功能)

## 开发

### 本地测试

```bash
make deps     # 安装依赖
make test     # 语法检查
make lint     # 代码质量检查
```

### 目录说明

- `lib/` - 公共函数库，被其他脚本引用
- 各模块目录包含独立的功能脚本
- 脚本支持独立运行和远程一键执行两种模式

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交 Issue 和 Pull Request。

- Bug 报告: [GitHub Issues](https://github.com/VocabVictor/linux-toolkit/issues)
- 功能建议: 通过 Pull Request 提交