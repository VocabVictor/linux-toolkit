#!/bin/bash
# Linux Toolkit - Zsh setup (standalone capable)
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Smart download function with GitHub proxy support
smart_download() {
    local url="$1"
    local output_file="$2"
    local use_proxy="${GITHUB_PROXY:-true}"
    
    # Add GitHub proxy for mainland China users
    if [ "$use_proxy" = "true" ] && [[ "$url" == *"raw.githubusercontent.com"* ]]; then
        local proxy_url="https://gh-proxy.com/$url"
        echo "INFO: Using GitHub proxy for better connectivity..."
        if curl -fsSL --connect-timeout 10 "$proxy_url" > "$output_file" 2>/dev/null; then
            return 0
        else
            echo "WARN: Proxy failed, trying direct connection..." >&2
        fi
    fi
    
    # Fallback to direct download
    curl -fsSL "$url" > "$output_file" || return 1
}

# Auto-detect if running standalone (via curl) or locally
# When piped from curl, BASH_SOURCE might not be available
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"

# Determine if we're in standalone mode
STANDALONE_MODE=true
if [ -n "$SCRIPT_SOURCE" ] && [[ "$SCRIPT_SOURCE" != *"http"* ]]; then
    # Check if common.sh exists relative to script location
    SCRIPT_DIR="$(dirname "$SCRIPT_SOURCE" 2>/dev/null || echo "")"
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
        STANDALONE_MODE=false
    fi
fi

if [ "$STANDALONE_MODE" = "true" ]; then
    # Standalone mode - download common.sh
    echo "INFO: Running in standalone mode, downloading dependencies..."
    TEMP_COMMON="/tmp/toolkit_common_$(date +%s).sh"
    smart_download "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/lib/common.sh" "$TEMP_COMMON" || {
        echo "ERROR: Failed to download common utilities" >&2
        exit 1
    }
    source "$TEMP_COMMON"
    rm -f "$TEMP_COMMON"
else
    # Local mode - use relative path
    source "$SCRIPT_DIR/../lib/common.sh"
fi

info "Installing Zsh + Oh My Zsh setup"

check_cmd zsh
check_cmd git
check_cmd curl

# Backup existing configs
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) && info "Backed up .zshrc"
[ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh ~/.p10k.zsh.backup.$(date +%Y%m%d_%H%M%S) && info "Backed up .p10k.zsh"

# Configure git to use proxy if needed
setup_git_proxy() {
    if [ "${GITHUB_PROXY:-true}" = "true" ] && ! git config --global http.proxy >/dev/null 2>&1; then
        info "Configuring git proxy for better GitHub connectivity..."
        git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"
    fi
}

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    # Download and verify install script
    local install_script="/tmp/omz-install.sh"
    smart_download "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "$install_script" || err "Failed to download Oh My Zsh installer"
    
    # Basic safety check - ensure it's the real installer
    if ! grep -q "Oh My Zsh" "$install_script" || ! grep -q "github.com/ohmyzsh" "$install_script"; then
        rm -f "$install_script"
        err "Downloaded script doesn't appear to be legitimate Oh My Zsh installer"
    fi
    
    # Run with explicit bash and cleanup
    bash "$install_script" --unattended || err "Oh My Zsh installation failed"
    rm -f "$install_script"
else
    info "Oh My Zsh already installed"
fi

# Setup git proxy for repository cloning
setup_git_proxy

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    info "Powerlevel10k theme already exists"
fi

# Install useful plugins
info "Installing useful plugins..."
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions"
fi

# zsh-syntax-highlighting  
if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting"
fi

# Create optimized .zshrc
info "Creating optimized .zshrc configuration..."
cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Essential plugins
plugins=(
    git
    docker
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    extract
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# Optimized settings
export LANG=en_US.UTF-8
export EDITOR='vim'
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Essential aliases
alias ll='ls -alF'
alias la='ls -A' 
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

ok "Zsh setup completed successfully!"
echo
info "Next steps:"
echo "1. Set zsh as default shell: chsh -s \$(which zsh)"
echo "2. Restart your terminal or run: exec zsh"
echo "3. Follow the Powerlevel10k configuration wizard"
echo
warn "Note: You may need to install a Nerd Font for best experience"
echo "      Recommended: https://github.com/romkatv/powerlevel10k#fonts"