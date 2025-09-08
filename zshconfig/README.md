# myzsh

一个现代化的 Zsh 配置自动安装脚本，让你的终端瞬间变得美观和高效！

## ✨ 特性

- 🎨 **Powerlevel10k** 主题 - 美观的彩虹色提示符
- 🚀 **智能插件** - 自动补全、语法高亮、历史建议
- 🛠️ **开箱即用** - 一键安装，无需手动配置
- 🌏 **中文优化** - 完美支持中文环境
- ⚡ **性能优化** - 快速启动和响应
- 📦 **丰富别名** - Git、Docker、系统命令快捷方式

## 🎯 安装的组件

### 主要框架
- **Oh My Zsh** - 流行的 Zsh 框架
- **Powerlevel10k** - 现代化主题，支持图标和状态显示

### 核心插件
- `zsh-autosuggestions` - 基于历史的智能命令建议
- `zsh-syntax-highlighting` - 实时语法高亮
- `zsh-completions` - 扩展自动补全功能
- `zsh-z` - 快速目录跳转
- `git` - Git 命令增强
- `docker` / `docker-compose` - Docker 支持
- `kubectl` - Kubernetes 命令补全
- `extract` - 万能解压功能
- `sudo` - 双击 ESC 自动添加 sudo
- `colored-man-pages` - 彩色帮助页面
- `command-not-found` - 命令未找到时的建议
- `history-substring-search` - 历史搜索增强

## 🚀 快速安装

### 前置要求
- Ubuntu/Debian: `sudo apt install zsh git curl`
- CentOS/RHEL: `sudo yum install zsh git curl`
- Arch Linux: `sudo pacman -S zsh git curl`

### 一键安装
```bash
# 下载并运行安装脚本
curl -fsSL https://gitee.com/bzzm/myzsh/raw/main/setup_zsh.sh | bash

# 或者手动下载后运行
git clone https://gitee.com/bzzm/myzsh.git
cd myzsh
chmod +x setup_zsh.sh
./setup_zsh.sh
```

### 设置默认 Shell
```bash
# 将 zsh 设为默认 shell
chsh -s $(which zsh)

# 重新登录或立即切换
exec zsh
```

## 📸 效果预览

安装完成后，你的终端将显示：
- 🎨 彩色的提示符，显示当前目录、Git 状态
- ⚡ 命令执行时间和退出状态
- 🔋 系统信息（可选）
- 📁 智能路径缩短显示

## 🎛️ 主要功能

### 智能补全
- **自动建议**：输入时灰色显示历史命令
- **Tab 补全**：强大的命令和参数自动补全
- **模糊匹配**：支持大小写不敏感的匹配

### Git 集成
快捷别名：
```bash
gs    # git status
ga    # git add
gc    # git commit -m
gp    # git push
gl    # git pull
gd    # git diff
gco   # git checkout
gb    # git branch
glog  # git log --oneline --graph --decorate
```

### 实用别名
```bash
ll    # ls -alF
la    # ls -A  
..    # cd ..
...   # cd ../..
cls   # clear
h     # history
df    # df -h
du    # du -h
ports # netstat -tulanp
```

### 实用函数
```bash
mkcd <dir>     # 创建并进入目录
backup <file>  # 备份文件（添加时间戳）
extract <file> # 智能解压各种格式
ff <name>      # 查找文件
fd <name>      # 查找目录
```

### 历史记录优化
- 保存 10万条历史记录
- 去重和时间戳
- 跨会话共享
- 智能搜索

## 🎨 自定义配置

### 重新配置主题
```bash
p10k configure
```

### 编辑配置文件
```bash
# 编辑 Zsh 配置
vim ~/.zshrc

# 编辑 Powerlevel10k 配置  
vim ~/.p10k.zsh
```

### 添加自定义插件
在 `~/.zshrc` 的 `plugins` 数组中添加：
```bash
plugins=(
    git
    # ... 现有插件
    你的插件名
)
```

## 📋 键盘快捷键

- `Ctrl + R` - 历史命令搜索
- `↑/↓` - 历史命令浏览  
- `→` 或 `End` - 接受自动建议
- `Ctrl + A` - 行首
- `Ctrl + E` - 行尾
- `Ctrl + L` - 清屏
- `Ctrl + C` - 取消当前命令

## ❓ 常见问题

### 字体问题
**问题**：主题显示乱码或方框
**解决**：安装 Nerd Font 字体
```bash
# 推荐字体：MesloLGS NF
# 下载地址：https://github.com/romkatv/powerlevel10k#fonts
```

### 慢启动问题
**问题**：Zsh 启动很慢
**解决**：检查插件加载，移除不需要的插件

### 补全不工作
**问题**：Tab 补全没反应
**解决**：
```bash
# 重新生成补全缓存
rm ~/.zcompdump*
exec zsh
```

### 主题配置丢失
**问题**：升级后主题变回默认
**解决**：
```bash
# 检查配置文件是否存在
ls -la ~/.p10k.zsh

# 重新配置
p10k configure
```

### Git 状态显示慢
**问题**：大仓库中 Git 状态显示缓慢
**解决**：在 `.zshrc` 中添加：
```bash
# 禁用大仓库的 Git 状态显示
POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=4096
```

## 🔧 故障排除

### 检查安装状态
```bash
# 检查 Oh My Zsh
ls ~/.oh-my-zsh

# 检查主题
ls ~/.oh-my-zsh/custom/themes/powerlevel10k

# 检查插件
ls ~/.oh-my-zsh/custom/plugins

# 检查配置
cat ~/.zshrc | grep -E "(ZSH_THEME|plugins)"
```

### 重新安装
```bash
# 备份现有配置
cp ~/.zshrc ~/.zshrc.backup
cp ~/.p10k.zsh ~/.p10k.zsh.backup

# 重新运行安装脚本
./setup_zsh.sh
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- 所有插件作者和贡献者

---

⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！