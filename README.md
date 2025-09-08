# Linux Toolkit 🛠️

现代化的 Linux 实用脚本工具包，提供终端美化、系统管理和开发环境配置的一键式解决方案。

## ⚡ 一键安装（推荐）

### 🌍 国际版 (GitHub 直连)
```bash
# Zsh 终端配置 - 安装 Oh My Zsh + Powerlevel10k
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash

# Docker 系统清理 - 清理未使用的容器和镜像
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# 系统垃圾清理 - 清理包缓存和临时文件
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash
```

### 🇨🇳 国内加速版 (推荐中国用户)
```bash
# Zsh 终端配置 - 安装 Oh My Zsh + Powerlevel10k
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash

# Docker 系统清理 - 清理未使用的容器和镜像
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# 系统垃圾清理 - 清理包缓存和临时文件
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash
```

## 📂 项目结构

```
linux-toolkit/
├── lib/               # 公共工具库和函数
├── zsh-config/        # Zsh 终端配置与美化
│   ├── setup.sh       # 一键安装脚本
│   └── uninstall.sh   # 卸载脚本
├── system/            # 系统管理与优化
│   ├── clean.sh       # 系统清理脚本
│   └── info.sh        # 系统信息查看
├── network/           # 网络工具与测试
│   └── speed.sh       # 网络速度测试
├── docker/            # Docker 管理工具
│   └── cleanup.sh     # Docker 清理脚本
├── backup/            # 数据备份工具
│   └── home.sh        # 家目录备份
└── .github/           # GitHub CI/CD 配置
```

## 🛠️ 本地使用

### 安装工具包
```bash
git clone https://github.com/VocabVictor/linux-toolkit.git
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
**一键安装：** `curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash`

**功能特性：**
- ✅ Oh My Zsh 框架自动安装
- ✅ Powerlevel10k 美观主题配置
- ✅ 智能命令补全与语法高亮
- ✅ Git 状态显示与快捷别名
- ✅ 支持中国大陆网络环境优化
- ✅ 自动备份现有配置文件

### 🧹 系统清理优化
**一键清理：** `curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash`

**清理内容：**
- ✅ APT/YUM/Pacman 包管理器缓存
- ✅ 用户临时文件和缓存目录
- ✅ 系统日志文件（保留最近7天）
- ✅ 浏览器缓存和下载文件
- ✅ 回收站和废纸篓清空

### 🐳 Docker 系统管理
**一键清理：** `curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash`

**清理范围：**
- ✅ 已停止的容器和孤立进程
- ✅ 未被使用的镜像和标签
- ✅ 悬空卷（dangling volumes）
- ✅ 未使用的网络和构建缓存
- ✅ 显示清理前后的空间对比

### 💾 数据备份工具
**本地执行：** `./backup/home.sh` 或克隆后使用

**备份功能：**
- ✅ 家目录重要文件智能备份
- ✅ 自动排除缓存和临时文件
- ✅ 支持增量备份和压缩存储
- ✅ 备份完整性校验机制
- ✅ 定期清理过期备份文件

### 🌐 网络诊断工具
**本地执行：** `./network/speed.sh` 或克隆后使用

**测试功能：**
- ✅ 多服务器节点网速测试
- ✅ 自动安装 speedtest-cli 工具
- ✅ 延迟、下载和上传速度检测
- ✅ 结果格式化输出和历史记录

## 🚀 高级使用

### 环境变量控制
```bash
# 禁用 GitHub 代理（直连模式）
GITHUB_PROXY=false curl -fsSL <script_url> | bash

# 静默模式（跳过交互确认）
BATCH=true curl -fsSL <script_url> | bash

# 组合模式（直连 + 静默）
GITHUB_PROXY=false BATCH=true curl -fsSL <script_url> | bash
```

### 预览脚本内容（建议执行前查看）
```bash
# 查看 Zsh 配置脚本内容
curl -s https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | less

# 查看系统清理脚本内容
curl -s https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | less
```

### 完整克隆仓库
```bash
# 国际版（直连 GitHub）
git clone https://github.com/VocabVictor/linux-toolkit.git
cd linux-toolkit

# 国内加速版（推荐中国用户）
git clone https://gh-proxy.com/https://github.com/VocabVictor/linux-toolkit.git
cd linux-toolkit
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

### 🎨 完整 Zsh 美化配置（推荐新手）
```bash
# 国际版（GitHub 直连）
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash

# 国内加速版（推荐中国用户）
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash

# 安装完成后设置为默认 Shell
chsh -s $(which zsh)

# 重新登录或执行以下命令立即生效
exec zsh
```

## ❓ 常见问题

### Q: 脚本执行安全吗？
A: 是的。所有脚本都包含完整性验证，执行前自动备份现有配置，具备完善的错误处理和回滚机制。建议执行前先预览脚本内容。

### Q: 中国大陆访问 GitHub 速度慢怎么办？
A: 脚本内置智能代理检测，自动使用 gh-proxy.com 镜像加速下载，超时后自动切换直连，无需手动干预。

### Q: 如何强制使用直连模式？
A: 在命令前添加 `GITHUB_PROXY=false` 环境变量即可跳过代理，直接连接 GitHub。

### Q: 如何卸载 Zsh 配置？
A: 执行 `./zsh-config/uninstall.sh` 卸载脚本，或手动恢复 `~/.zshrc.backup` 等备份文件。

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

- 🐛 Bug 报告：[GitHub Issues](https://github.com/VocabVictor/linux-toolkit/issues)
- 💡 功能建议：欢迎提交 Pull Request
