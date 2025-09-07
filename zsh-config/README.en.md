# myzsh

A modern Zsh configuration auto-installer script that makes your terminal beautiful and efficient instantly!

## ✨ Features

- 🎨 **Powerlevel10k** theme - Beautiful rainbow-colored prompt
- 🚀 **Smart plugins** - Auto-completion, syntax highlighting, history suggestions
- 🛠️ **Out-of-the-box** - One-click installation, no manual configuration
- 🌏 **Chinese optimized** - Perfect support for Chinese environment
- ⚡ **Performance optimized** - Fast startup and response
- 📦 **Rich aliases** - Git, Docker, system command shortcuts

## 🎯 Installed Components

### Main Frameworks
- **Oh My Zsh** - Popular Zsh framework
- **Powerlevel10k** - Modern theme with icons and status display

### Core Plugins
- `zsh-autosuggestions` - Smart command suggestions based on history
- `zsh-syntax-highlighting` - Real-time syntax highlighting
- `zsh-completions` - Extended auto-completion functionality
- `zsh-z` - Quick directory jumping
- `git` - Git command enhancements
- `docker` / `docker-compose` - Docker support
- `kubectl` - Kubernetes command completion
- `extract` - Universal extract function
- `sudo` - Double ESC to add sudo automatically
- `colored-man-pages` - Colored manual pages
- `command-not-found` - Suggestions when command not found
- `history-substring-search` - Enhanced history search

## 🚀 Quick Installation

### Prerequisites
- Ubuntu/Debian: `sudo apt install zsh git curl`
- CentOS/RHEL: `sudo yum install zsh git curl`
- Arch Linux: `sudo pacman -S zsh git curl`

### One-click Installation
```bash
# Download and run install script
curl -fsSL https://gitee.com/bzzm/myzsh/raw/main/setup_zsh.sh | bash

# Or manually download and run
git clone https://gitee.com/bzzm/myzsh.git
cd myzsh
chmod +x setup_zsh.sh
./setup_zsh.sh
```

### Set Default Shell
```bash
# Set zsh as default shell
chsh -s $(which zsh)

# Re-login or switch immediately
exec zsh
```

## 📸 Preview

After installation, your terminal will display:
- 🎨 Colorful prompt showing current directory and Git status
- ⚡ Command execution time and exit status
- 🔋 System information (optional)
- 📁 Smart path shortening display

## 🎛️ Main Features

### Smart Completion
- **Auto suggestions**: Gray text showing historical commands while typing
- **Tab completion**: Powerful command and parameter auto-completion
- **Fuzzy matching**: Case-insensitive matching support

### Git Integration
Quick aliases:
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

### Useful Aliases
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

### Utility Functions
```bash
mkcd <dir>     # Create and enter directory
backup <file>  # Backup file (add timestamp)
extract <file> # Smart extraction for various formats
ff <name>      # Find files
fd <name>      # Find directories
```

### History Optimization
- Save 100,000 history records
- Deduplication and timestamps
- Cross-session sharing
- Smart search

## 🎨 Custom Configuration

### Reconfigure Theme
```bash
p10k configure
```

### Edit Configuration Files
```bash
# Edit Zsh configuration
vim ~/.zshrc

# Edit Powerlevel10k configuration  
vim ~/.p10k.zsh
```

### Add Custom Plugins
Add to the `plugins` array in `~/.zshrc`:
```bash
plugins=(
    git
    # ... existing plugins
    your-plugin-name
)
```

## 📋 Keyboard Shortcuts

- `Ctrl + R` - History command search
- `↑/↓` - Browse history commands  
- `→` or `End` - Accept auto suggestion
- `Ctrl + A` - Beginning of line
- `Ctrl + E` - End of line
- `Ctrl + L` - Clear screen
- `Ctrl + C` - Cancel current command

## ❓ FAQ

### Font Issues
**Problem**: Theme displays garbled characters or boxes
**Solution**: Install Nerd Font
```bash
# Recommended font: MesloLGS NF
# Download: https://github.com/romkatv/powerlevel10k#fonts
```

### Slow Startup
**Problem**: Zsh starts slowly
**Solution**: Check plugin loading, remove unnecessary plugins

### Completion Not Working
**Problem**: Tab completion not responding
**Solution**:
```bash
# Regenerate completion cache
rm ~/.zcompdump*
exec zsh
```

### Theme Configuration Lost
**Problem**: Theme reverts to default after upgrade
**Solution**:
```bash
# Check if config file exists
ls -la ~/.p10k.zsh

# Reconfigure
p10k configure
```

### Git Status Display Slow
**Problem**: Git status display slow in large repositories
**Solution**: Add to `.zshrc`:
```bash
# Disable Git status display for large repos
POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=4096
```

## 🔧 Troubleshooting

### Check Installation Status
```bash
# Check Oh My Zsh
ls ~/.oh-my-zsh

# Check theme
ls ~/.oh-my-zsh/custom/themes/powerlevel10k

# Check plugins
ls ~/.oh-my-zsh/custom/plugins

# Check configuration
cat ~/.zshrc | grep -E "(ZSH_THEME|plugins)"
```

### Reinstall
```bash
# Backup existing configuration
cp ~/.zshrc ~/.zshrc.backup
cp ~/.p10k.zsh ~/.p10k.zsh.backup

# Re-run install script
./setup_zsh.sh
```

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork this repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- All plugin authors and contributors

---

⭐ If this project helps you, please give it a Star!