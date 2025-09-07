# Linux Toolkit 🛠️

现代化的 Linux 实用脚本工具包，支持一键安装，无需克隆仓库！

## ⚡ 一键安装（推荐）

### 🌍 国际版 (GitHub 直连)
```bash
# Zsh 完整配置
curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | bash

# Docker 清理
curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/docker/cleanup.sh | bash

# 系统清理
curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/system/clean.sh | bash
```

### 🇨🇳 国内加速版 (推荐中国用户)
```bash
# Zsh 完整配置  
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | bash

# Docker 清理
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/yourusername/linux-toolkit/main/docker/cleanup.sh | bash

# 系统清理
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/yourusername/linux-toolkit/main/system/clean.sh | bash
```

## 📂 项目结构

```
linux-toolkit/
├── lib/               # 公共工具库
├── zsh-config/        # Zsh 终端配置和美化
├── system/            # 系统管理脚本  
├── network/           # 网络工具和测试
├── docker/            # Docker 管理脚本
├── backup/            # 数据备份脚本
└── .github/           # CI/CD 配置
```

## 🛠️ 本地使用

### 安装工具包
```bash
git clone https://github.com/yourusername/linux-toolkit.git
cd linux-toolkit
make install  # 安装到 ~/bin
```

### 运行测试
```bash
make test     # 语法检查
make lint     # 代码质量检查
```

## ✨ 智能特性

- 🌐 **智能 GitHub 代理** - 自动检测并使用 gh-proxy.com 加速访问
- 🔧 **动态依赖下载** - 脚本自动下载所需的公共库
- 🔄 **网络容错机制** - 代理失败自动切换直连
- 📱 **双模式兼容** - 支持本地运行和远程一键执行
- 🔒 **安全验证** - 下载脚本完整性检查
- 💾 **配置备份** - 自动备份现有配置文件

## 📦 功能模块

### 🎨 Zsh 终端美化
**一键命令：** `curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | bash`

包含：
- ✅ Oh My Zsh 框架
- ✅ Powerlevel10k 主题  
- ✅ zsh-autosuggestions 自动建议
- ✅ zsh-syntax-highlighting 语法高亮
- ✅ 优化的配置和别名

### 🧹 系统清理优化
**一键命令：** `curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/system/clean.sh | bash`

功能：
- ✅ 包管理器缓存清理
- ✅ 用户缓存清理
- ✅ 安全的临时文件清理
- ✅ 日志文件管理

### 🐳 Docker 管理
**一键命令：** `curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/docker/cleanup.sh | bash`

功能：
- ✅ 停止的容器清理
- ✅ 未使用的镜像清理
- ✅ 孤立卷和网络清理
- ✅ 构建缓存清理

### 💾 数据备份
本地使用：`./backup/home.sh`

功能：
- ✅ 主目录智能备份
- ✅ 自动排除临时文件
- ✅ 备份完整性验证  
- ✅ 旧备份自动轮转

### 🌐 网络工具
本地使用：`./network/speed.sh`

功能：
- ✅ 网速测试
- ✅ 自动安装测试工具
- ✅ 版本固定安装

## 🚀 高级使用

### 环境变量控制
```bash
# 禁用 GitHub 代理（直连）
GITHUB_PROXY=false curl -fsSL <script_url> | bash

# 静默模式（非交互）
BATCH=true curl -fsSL <script_url> | bash

# 组合使用
GITHUB_PROXY=false BATCH=true curl -fsSL <script_url> | bash
```

### 预览脚本内容
```bash
curl -s https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | less
```

### 克隆仓库
```bash
# 国际版
git clone https://github.com/yourusername/linux-toolkit.git

# 国内加速版
git clone https://gh-proxy.com/https://github.com/yourusername/linux-toolkit.git
```

### 本地开发
```bash
# 安装依赖
make deps

# 运行测试
make test

# 代码检查  
make lint

# 安装到系统
make install
```

## 🔧 核心特性

### 智能网络优化
- 🌍 **中国大陆优化**：自动使用 gh-proxy.com 加速 GitHub 访问
- ⚡ **快速切换**：10秒超时后自动降级直连
- 🔄 **Git 代理**：自动配置 git clone 代理加速

### 安全可靠
- ✅ **脚本验证**：下载脚本完整性检查
- 💾 **配置备份**：自动备份现有配置  
- 🔒 **错误处理**：完整的异常处理机制
- 🧹 **自动清理**：临时文件自动删除

### 跨平台支持
- 🐧 Ubuntu/Debian
- 🎩 CentOS/RHEL  
- 🏗️ Arch Linux
- 🍎 macOS (部分功能)

## 📝 快速示例

### 🎨 完整 Zsh 美化（最受欢迎）
```bash
# 国际版
curl -fsSL https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | bash

# 国内加速版
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/yourusername/linux-toolkit/main/zsh-config/setup.sh | bash

# 设置默认 shell
chsh -s $(which zsh)

# 重启终端即可使用
```

## ❓ 常见问题

### Q: 脚本安全吗？
A: 所有脚本都包含完整性检查，会自动备份现有配置，并有详细的错误处理机制。

### Q: 中国大陆网络慢怎么办？
A: 脚本自动使用 gh-proxy.com 代理加速，无需手动配置。

### Q: 可以禁用代理吗？
A: 使用 `GITHUB_PROXY=false` 环境变量即可禁用代理。

### Q: 如何卸载 Zsh 配置？
A: 运行 `./zsh-config/uninstall.sh` 或直接恢复备份的配置文件。

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

## 🌟 项目亮点

- 🚀 **真正一键安装** - 无需克隆仓库，直接 curl 执行
- 🌍 **中国用户友好** - 自动代理加速，解决网络问题  
- 🔧 **工程化标准** - 完整的 CI/CD、代码检查、错误处理
- 📦 **模块化设计** - 每个脚本独立运行，按需使用
- 🔒 **安全第一** - 配置备份、脚本验证、异常恢复

---

⭐ **如果这个项目对你有帮助，请给个 Star 支持一下！**

## 📮 问题反馈

- 🐛 Bug 报告：[GitHub Issues](https://github.com/yourusername/linux-toolkit/issues)
- 💡 功能建议：欢迎提交 Pull Request
- 📧 联系作者：your-email@example.com