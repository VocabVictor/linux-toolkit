#!/bin/bash

# Enhanced Zsh + Oh My Zsh Auto Setup Script
# Version: 2.0
# Author: myzsh project
# Description: Robust installation with network checks, retries and custom options

set -euo pipefail  # 严格错误处理

# 配置变量
readonly SCRIPT_VERSION="2.0"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2
readonly GITHUB_PROXY="https://gh-proxy.com/"
readonly DEFAULT_TIMEOUT=30

# 颜色输出
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# 全局变量
CUSTOM_INSTALL=false
SELECTED_PLUGINS=()
INSTALL_FZF=false
INSTALL_BAT=false
INSTALL_EXA=false

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 错误处理
error_exit() {
    log_error "$1"
    exit 1
}

# 网络连接检查
check_network() {
    local test_urls=(
        "github.com"
        "gitee.com"
        "raw.githubusercontent.com"
    )
    
    log_info "检查网络连接..."
    
    for url in "${test_urls[@]}"; do
        if timeout 10 ping -c 1 "$url" &>/dev/null; then
            log_success "网络连接正常"
            return 0
        fi
    done
    
    log_warning "网络连接可能不稳定"
    read -p "是否继续安装? (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || error_exit "用户取消安装"
}

# 重试函数
retry_command() {
    local cmd="$1"
    local desc="$2"
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        log_info "执行: $desc (尝试 $((retries + 1))/$MAX_RETRIES)"
        
        if eval "$cmd"; then
            log_success "$desc 成功"
            return 0
        fi
        
        retries=$((retries + 1))
        if [ $retries -lt $MAX_RETRIES ]; then
            log_warning "$desc 失败，$RETRY_DELAY 秒后重试..."
            sleep $RETRY_DELAY
        fi
    done
    
    log_error "$desc 失败，已重试 $MAX_RETRIES 次"
    return 1
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    local deps=("zsh" "git" "curl")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "缺少依赖: ${missing_deps[*]}"
        echo "请安装缺少的依赖："
        echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "  CentOS/RHEL: sudo yum install ${missing_deps[*]}"
        echo "  Arch Linux: sudo pacman -S ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        exit 1
    fi
    
    log_success "所有依赖已满足"
}

# 系统信息
detect_system() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &>/dev/null; then
            echo "debian"
        elif command -v yum &>/dev/null; then
            echo "redhat"
        elif command -v pacman &>/dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# 交互式配置
interactive_config() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    Zsh 自定义安装配置${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    read -p "是否使用自定义安装选项? (y/n) [n]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        CUSTOM_INSTALL=true
        
        # 插件选择
        echo "选择要安装的插件 (输入数字，用空格分隔):"
        echo "1) zsh-autosuggestions (推荐)"
        echo "2) zsh-syntax-highlighting (推荐)"
        echo "3) zsh-completions (推荐)"
        echo "4) zsh-z (目录跳转)"
        echo "5) autojump (替代 zsh-z)"
        echo "6) fast-syntax-highlighting (高性能语法高亮)"
        echo "7) zsh-history-substring-search"
        
        read -p "选择插件 [1 2 3 4]: " plugin_choice
        plugin_choice=${plugin_choice:-"1 2 3 4"}
        
        IFS=' ' read -ra SELECTED_PLUGINS <<< "$plugin_choice"
        
        # 额外工具
        read -p "安装 fzf (模糊搜索)? (y/n) [y]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] || INSTALL_FZF=true
        
        read -p "安装 bat (更好的 cat)? (y/n) [n]: " -n 1 -r  
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_BAT=true
        
        read -p "安装 exa (现代化的 ls)? (y/n) [n]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_EXA=true
    else
        # 默认安装
        SELECTED_PLUGINS=(1 2 3 4)
        INSTALL_FZF=true
    fi
}

# 备份现有配置
backup_configs() {
    log_info "备份现有配置..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.config/zsh_backup_$timestamp"
    
    mkdir -p "$backup_dir"
    
    for file in ~/.zshrc ~/.p10k.zsh ~/.oh-my-zsh; do
        if [[ -e "$file" ]]; then
            cp -r "$file" "$backup_dir/"
            log_success "已备份: $file -> $backup_dir/"
        fi
    done
    
    echo "备份目录: $backup_dir" > "$HOME/.zsh_backup_location"
}

# 安装 Oh My Zsh
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh 已存在，跳过安装"
        return 0
    fi
    
    log_info "安装 Oh My Zsh..."
    local install_cmd="sh -c \"\$(curl -fsSL ${GITHUB_PROXY}https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
    
    retry_command "$install_cmd" "Oh My Zsh 安装" || error_exit "Oh My Zsh 安装失败"
}

# 安装 Powerlevel10k
install_powerlevel10k() {
    log_info "安装 Powerlevel10k 主题..."
    
    local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$theme_dir" ]]; then
        log_warning "Powerlevel10k 已存在，更新中..."
        retry_command "cd '$theme_dir' && git pull" "Powerlevel10k 更新"
    else
        local clone_cmd="git clone --depth=1 ${GITHUB_PROXY}https://github.com/romkatv/powerlevel10k.git '$theme_dir'"
        retry_command "$clone_cmd" "Powerlevel10k 克隆"
    fi
}

# 下载 p10k 配置
download_p10k_config() {
    log_info "下载 Powerlevel10k 配置..."
    
    local p10k_url="${GITHUB_PROXY}https://raw.githubusercontent.com/VocabVictor/myzsh/refs/heads/main/p10k.zsh"
    local download_cmd="curl -fsSL --connect-timeout $DEFAULT_TIMEOUT '$p10k_url' -o ~/.p10k.zsh.tmp"
    
    if retry_command "$download_cmd" "P10k 配置下载"; then
        if [[ -s ~/.p10k.zsh.tmp ]]; then
            mv ~/.p10k.zsh.tmp ~/.p10k.zsh
            log_success "P10k 配置下载成功 ($(wc -l < ~/.p10k.zsh) 行)"
        else
            rm -f ~/.p10k.zsh.tmp
            log_warning "下载的配置文件为空，将使用默认配置"
        fi
    else
        log_warning "配置下载失败，将使用默认配置"
    fi
}

# 安装插件
install_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    
    if [[ -d "$plugin_dir" ]]; then
        log_warning "$plugin_name 已存在，更新中..."
        retry_command "cd '$plugin_dir' && git pull" "$plugin_name 更新"
    else
        log_info "安装 $plugin_name..."
        local clone_cmd="git clone ${GITHUB_PROXY}$repo_url '$plugin_dir'"
        retry_command "$clone_cmd" "$plugin_name 安装"
    fi
}

# 安装选中的插件
install_selected_plugins() {
    local plugins_map=(
        "1:zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "2:zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "3:zsh-completions:https://github.com/zsh-users/zsh-completions"
        "4:zsh-z:https://github.com/agkozak/zsh-z"
        "5:autojump:https://github.com/wting/autojump.git"
        "6:fast-syntax-highlighting:https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
        "7:zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search.git"
    )
    
    for selection in "${SELECTED_PLUGINS[@]}"; do
        for plugin_info in "${plugins_map[@]}"; do
            IFS=':' read -r num name url <<< "$plugin_info"
            if [[ "$num" == "$selection" ]]; then
                install_plugin "$name" "$url"
                break
            fi
        done
    done
}

# 安装额外工具
install_extra_tools() {
    local system=$(detect_system)
    
    if [[ "$INSTALL_FZF" == true ]]; then
        log_info "安装 fzf..."
        case $system in
            "debian")
                sudo apt install -y fzf 2>/dev/null || {
                    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                    ~/.fzf/install --all
                }
                ;;
            "arch")
                sudo pacman -S --noconfirm fzf 2>/dev/null || true
                ;;
            "macos")
                brew install fzf 2>/dev/null || true
                ;;
        esac
    fi
    
    if [[ "$INSTALL_BAT" == true ]]; then
        log_info "安装 bat..."
        case $system in
            "debian")
                sudo apt install -y bat 2>/dev/null || true
                ;;
            "arch") 
                sudo pacman -S --noconfirm bat 2>/dev/null || true
                ;;
            "macos")
                brew install bat 2>/dev/null || true
                ;;
        esac
    fi
    
    if [[ "$INSTALL_EXA" == true ]]; then
        log_info "安装 exa..."
        case $system in
            "debian")
                sudo apt install -y exa 2>/dev/null || true
                ;;
            "arch")
                sudo pacman -S --noconfirm exa 2>/dev/null || true
                ;;
            "macos")
                brew install exa 2>/dev/null || true
                ;;
        esac
    fi
}

# 生成 zshrc 配置
generate_zshrc() {
    log_info "生成 .zshrc 配置..."
    
    # 构建插件列表
    local plugin_names=("git")
    
    for selection in "${SELECTED_PLUGINS[@]}"; do
        case $selection in
            1) plugin_names+=("zsh-autosuggestions") ;;
            2) plugin_names+=("zsh-syntax-highlighting") ;;
            3) plugin_names+=("zsh-completions") ;;
            4) plugin_names+=("zsh-z") ;;
            5) plugin_names+=("autojump") ;;
            6) plugin_names+=("fast-syntax-highlighting") ;;
            7) plugin_names+=("history-substring-search") ;;
        esac
    done
    
    # 添加常用插件
    plugin_names+=("extract" "sudo" "colored-man-pages" "command-not-found")
    
    # 生成配置文件
    cat > ~/.zshrc << EOF
# Enable Powerlevel10k instant prompt
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

# Path to oh-my-zsh
export ZSH="\$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=($(printf "%s\n" "${plugin_names[@]}" | sort -u | tr '\n' ' '))

source \$ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'
export PATH=\$HOME/bin:\$HOME/.local/bin:\$PATH

# History optimization
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_FIND_NO_DUPS

# Auto-suggestion configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# System aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='grep --color=auto'
alias cls='clear'
alias h='history'
alias path='echo -e \${PATH//:/\\\\n}'
alias ports='netstat -tulanp'
EOF

    # 添加额外工具的别名
    if [[ "$INSTALL_BAT" == true ]]; then
        echo "alias cat='bat'" >> ~/.zshrc
    fi
    
    if [[ "$INSTALL_EXA" == true ]]; then
        echo "alias ls='exa'" >> ~/.zshrc
        echo "alias ll='exa -alF'" >> ~/.zshrc
        echo "alias la='exa -A'" >> ~/.zshrc
    fi
    
    # 添加实用函数
    cat >> ~/.zshrc << 'EOF'

# Utility functions
mkcd() { mkdir -p "$1" && cd "$1"; }
backup() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

ff() { find . -type f -name "*$1*" ; }
fd() { find . -type d -name "*$1*" ; }

# Auto-completion
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Load p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    log_success ".zshrc 配置已生成"
}

# 安装验证
verify_installation() {
    log_info "验证安装..."
    
    local errors=()
    
    [[ -d ~/.oh-my-zsh ]] || errors+=("Oh My Zsh 目录不存在")
    [[ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]] || errors+=("Powerlevel10k 主题不存在")
    [[ -f ~/.zshrc ]] || errors+=(".zshrc 配置文件不存在")
    
    if [[ ${#errors[@]} -gt 0 ]]; then
        log_error "安装验证失败:"
        printf '%s\n' "${errors[@]}"
        return 1
    fi
    
    log_success "安装验证通过"
}

# 显示安装摘要
show_summary() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}安装摘要 - myzsh v$SCRIPT_VERSION${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # 检查安装状态
    [[ -d ~/.oh-my-zsh ]] && echo -e "${GREEN}✓ Oh My Zsh${NC}" || echo -e "${RED}✗ Oh My Zsh${NC}"
    [[ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]] && echo -e "${GREEN}✓ Powerlevel10k 主题${NC}" || echo -e "${RED}✗ Powerlevel10k 主题${NC}"
    [[ -f ~/.p10k.zsh ]] && echo -e "${GREEN}✓ P10k 配置文件${NC}" || echo -e "${YELLOW}! P10k 配置文件（将使用默认）${NC}"
    
    # 显示安装的插件
    echo -e "${GREEN}已安装插件:${NC}"
    for selection in "${SELECTED_PLUGINS[@]}"; do
        case $selection in
            1) echo -e "${GREEN}  ✓ zsh-autosuggestions${NC}" ;;
            2) echo -e "${GREEN}  ✓ zsh-syntax-highlighting${NC}" ;;
            3) echo -e "${GREEN}  ✓ zsh-completions${NC}" ;;
            4) echo -e "${GREEN}  ✓ zsh-z${NC}" ;;
            5) echo -e "${GREEN}  ✓ autojump${NC}" ;;
            6) echo -e "${GREEN}  ✓ fast-syntax-highlighting${NC}" ;;
            7) echo -e "${GREEN}  ✓ history-substring-search${NC}" ;;
        esac
    done
    
    # 显示额外工具
    [[ "$INSTALL_FZF" == true ]] && echo -e "${GREEN}  ✓ fzf${NC}"
    [[ "$INSTALL_BAT" == true ]] && echo -e "${GREEN}  ✓ bat${NC}"
    [[ "$INSTALL_EXA" == true ]] && echo -e "${GREEN}  ✓ exa${NC}"
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}配置完成！${NC}"
    echo -e "${GREEN}注意：Powerlevel10k 需要 Nerd Font 字体支持${NC}"
    echo -e "${GREEN}推荐字体：MesloLGS NF${NC}"
    echo -e "${GREEN}下载地址：https://github.com/romkatv/powerlevel10k#fonts${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}请运行以下命令设置 zsh 为默认 shell:${NC}"
    echo -e "${GREEN}  chsh -s \$(which zsh)${NC}"
    echo -e "${GREEN}然后重新登录或运行: exec zsh${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 主函数
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Enhanced Zsh Setup v$SCRIPT_VERSION${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # 检查网络和依赖
    check_network
    check_dependencies
    
    # 交互式配置
    interactive_config
    
    # 安装流程
    backup_configs
    install_oh_my_zsh
    install_powerlevel10k
    download_p10k_config
    install_selected_plugins
    install_extra_tools
    generate_zshrc
    
    # 验证和总结
    verify_installation
    show_summary
    
    # 询问是否立即切换
    read -p "是否现在切换到 zsh? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec zsh
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi