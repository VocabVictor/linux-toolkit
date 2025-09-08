#!/bin/bash
# Linux Toolkit - Zsh setup (standalone capable)
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zsh-config/setup.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

info "Installing Zsh + Oh My Zsh setup"

# Function to install zsh from source to ~/.local/bin
install_zsh_local() {
    local ZSH_VERSION="5.9"
    local INSTALL_DIR="$HOME/.local"
    local BUILD_DIR="$INSTALL_DIR/src/zsh-$ZSH_VERSION"
    
    # Cleanup function
    cleanup_build() {
        info "Cleaning up build directory..."
        rm -rf "$BUILD_DIR"* 2>/dev/null || true
    }
    
    # Set trap for cleanup on exit
    trap cleanup_build EXIT
    
    info "Zsh not found in system, installing to $INSTALL_DIR/bin..."
    
    # Create directories
    mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/src"
    
    # Install build dependencies if possible
    if command -v apt-get >/dev/null 2>&1; then
        info "Installing build dependencies..."
        sudo apt-get update && sudo apt-get install -y build-essential libncurses5-dev libncursesw5-dev 2>/dev/null || true
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y gcc make ncurses-devel 2>/dev/null || true
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y gcc make ncurses-devel 2>/dev/null || true
    fi
    
    # Download and extract zsh source
    cd "$INSTALL_DIR/src"
    info "Downloading zsh $ZSH_VERSION source code..."
    smart_download "https://sourceforge.net/projects/zsh/files/zsh/$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz/download" "zsh-$ZSH_VERSION.tar.xz" || {
        # Fallback to GitHub mirror
        smart_download "https://github.com/zsh-users/zsh/releases/download/zsh-$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz" "zsh-$ZSH_VERSION.tar.xz" || {
            err "Failed to download zsh source code"
        }
    }
    
    tar -xf "zsh-$ZSH_VERSION.tar.xz" || err "Failed to extract zsh source"
    cd "zsh-$ZSH_VERSION"
    
    # Configure and compile
    info "Configuring zsh build..."
    ./configure --prefix="$INSTALL_DIR" --enable-multibyte --enable-function-subdirs \
                --with-tcsetpgrp --enable-pcre --enable-cap --enable-zsh-secure-free || err "Failed to configure zsh"
    
    info "Compiling zsh (this may take a few minutes)..."
    make -j$(nproc 2>/dev/null || echo 1) || err "Failed to compile zsh"
    
    info "Installing zsh to $INSTALL_DIR..."
    make install || err "Failed to install zsh"
    
    # Cleanup handled by trap
    cd "$HOME"
    
    # Add ~/.local/bin to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        info "Adding $HOME/.local/bin to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    ok "Zsh installed successfully to $INSTALL_DIR/bin/zsh"
}

# Check for zsh, install if not found
if ! command -v zsh >/dev/null 2>&1; then
    install_zsh_local
else
    info "Zsh is already installed: $(command -v zsh)"
fi

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
    # Clone directly from official repository with specific commit for safety
    OMZ_COMMIT="master"  # Consider pinning to specific commit for production
    git clone --depth=1 --branch "$OMZ_COMMIT" https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || err "Failed to clone Oh My Zsh repository"
    
    # Copy default zshrc template
    if [ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]; then
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc.omz-template"
    fi
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