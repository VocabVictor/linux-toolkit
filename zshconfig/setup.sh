#!/bin/bash
# Linux Toolkit - Zsh setup (simplified)
# Usage: ./zshconfig/setup.sh
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

info "Installing Zsh + Oh My Zsh setup"

# Check for zsh
if ! command -v zsh >/dev/null 2>&1; then
    err "zsh not found. Please install it first:
  Ubuntu/Debian: sudo apt install zsh
  CentOS/RHEL: sudo yum install zsh
  Arch: sudo pacman -S zsh
  macOS: brew install zsh"
fi

# Clean up any previous failed installations
info "Cleaning up previous installations..."
rm -rf ~/.oh-my-zsh.tmp ~/.p10k.tmp 2>/dev/null || true

# Backup existing config (only once)
if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.backup ]; then
    info "Backing up existing .zshrc"
    cp ~/.zshrc ~/.zshrc.backup
fi

if [ -f ~/.p10k.zsh ] && [ ! -f ~/.p10k.zsh.backup ]; then
    info "Backing up existing .p10k.zsh"
    cp ~/.p10k.zsh ~/.p10k.zsh.backup
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh.tmp
    mv ~/.oh-my-zsh.tmp ~/.oh-my-zsh
else
    info "Oh My Zsh already installed"
fi

# Install Powerlevel10k theme
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.p10k.tmp
    mv ~/.p10k.tmp "$P10K_DIR"
else
    info "Powerlevel10k theme already exists"
fi

# Install plugins
info "Installing useful plugins..."
PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

# zsh-autosuggestions
if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
fi

# Create optimized .zshrc
info "Creating optimized .zshrc configuration..."
cat > ~/.zshrc << 'EOF'
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    kubectl
    helm
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
EOF

# Create basic Powerlevel10k config if not exists
if [ ! -f ~/.p10k.zsh ]; then
    info "Creating basic Powerlevel10k configuration..."
    cat > ~/.p10k.zsh << 'EOF'
# Powerlevel10k configuration
# Run `p10k configure` to customize

# Elements to show
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir
    vcs
    prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    time
)

# Prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196

# Directory
typeset -g POWERLEVEL9K_DIR_FOREGROUND=31

# Git
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178

# Time
typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
EOF
fi

ok "Zsh setup completed successfully!"

info "Next steps:
1. Set zsh as default shell: chsh -s \$(which zsh)
2. Restart your terminal or run: exec zsh
3. Run 'p10k configure' to customize your prompt

Recommended: Install a Nerd Font for best experience"
warn "Note: You may need to install a Nerd Font for best experience"