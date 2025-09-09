#!/bin/bash
# Linux Toolkit - Zsh setup
# Usage: ./zshconfig/setup.sh
# Copyright (c) 2025 Linux Toolkit. MIT License.

# Source functions - download if needed (for curl | bash support)
# Use safer BASH_SOURCE detection that works with curl | bash
if [ "${#BASH_SOURCE[@]}" -gt 0 ] && [ -f "${BASH_SOURCE[0]}" ]; then
    # Local execution - use local common.sh
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/../lib/common.sh"
else
    # Standalone execution - download common.sh
    TEMP_COMMON="/tmp/common_$$.sh"
    trap "rm -f $TEMP_COMMON" EXIT
    
    # Download common.sh from GitHub
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/lib/common.sh" > "$TEMP_COMMON" || {
            echo "ERROR: Failed to download dependencies" >&2
            exit 1
        }
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$TEMP_COMMON" "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/lib/common.sh" || {
            echo "ERROR: Failed to download dependencies" >&2
            exit 1
        }
    else
        echo "ERROR: Neither curl nor wget available" >&2
        exit 1
    fi
    
    source "$TEMP_COMMON"
fi

# Set strict mode after BASH_SOURCE handling
set -euo pipefail

info "Installing Zsh + Oh My Zsh setup"

# Function to compile ncurses locally (for restricted environments)
compile_ncurses() {
    local INSTALL_DIR="$HOME/.local"
    local NCURSES_VERSION="6.4"
    
    info "Compiling ncurses $NCURSES_VERSION locally..."
    
    # Clean up any previous builds
    rm -rf "$INSTALL_DIR/src/ncurses-"* "$INSTALL_DIR/lib"/libncurses* "$INSTALL_DIR/lib"/libtinfo*
    
    mkdir -p "$INSTALL_DIR/src"
    cd "$INSTALL_DIR/src"
    
    # Download and extract
    smart_download "https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VERSION.tar.gz" "ncurses-$NCURSES_VERSION.tar.gz" || {
        warn "Failed to download ncurses"
        return 1
    }
    
    tar -xf "ncurses-$NCURSES_VERSION.tar.gz"
    cd "ncurses-$NCURSES_VERSION"
    
    # Configure with shared libraries only
    export CFLAGS="-fPIC -O2"
    ./configure \
        --prefix="$INSTALL_DIR" \
        --enable-shared \
        --disable-static \
        --enable-widec \
        --without-debug \
        --without-ada \
        --without-cxx \
        --enable-overwrite \
        --with-shared \
        --enable-pc-files \
        --with-pkg-config-libdir="$INSTALL_DIR/lib/pkgconfig" \
        --with-termlib \
        >/dev/null 2>&1 || {
            warn "ncurses configure failed"
            return 1
        }
    
    # Compile and install
    make -j$(nproc 2>/dev/null || echo 1) libs >/dev/null 2>&1 || {
        warn "ncurses compilation failed"
        return 1
    }
    
    make install.libs >/dev/null 2>&1 || {
        warn "ncurses installation failed"
        return 1
    }
    
    # Verify installation
    if [ ! -f "$INSTALL_DIR/lib/libncursesw.so" ]; then
        warn "ncurses installation verification failed"
        return 1
    fi
    
    # Cleanup
    cd "$HOME"
    rm -rf "$INSTALL_DIR/src/ncurses-$NCURSES_VERSION"*
    
    ok "ncurses compiled successfully"
    return 0
}

# Function to compile zsh locally (for restricted environments)
compile_zsh() {
    local INSTALL_DIR="$HOME/.local"
    local ZSH_VERSION="5.9"
    
    info "Compiling zsh $ZSH_VERSION locally..."
    
    # Clean up any previous builds
    rm -rf "$INSTALL_DIR/src/zsh-"*
    
    mkdir -p "$INSTALL_DIR/src" "$INSTALL_DIR/bin"
    cd "$INSTALL_DIR/src"
    
    # Download and extract
    smart_download "https://sourceforge.net/projects/zsh/files/zsh/$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz/download" "zsh-$ZSH_VERSION.tar.xz" || {
        warn "Failed to download zsh"
        return 1
    }
    
    tar -xf "zsh-$ZSH_VERSION.tar.xz"
    cd "zsh-$ZSH_VERSION"
    
    # Set up environment for local ncurses
    export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export LD_LIBRARY_PATH="$INSTALL_DIR/lib:${LD_LIBRARY_PATH:-}"
    export CPPFLAGS="-I$INSTALL_DIR/include"
    export LDFLAGS="-L$INSTALL_DIR/lib -Wl,-rpath,$INSTALL_DIR/lib"
    
    # Configure zsh
    ./configure \
        --prefix="$INSTALL_DIR" \
        --enable-multibyte \
        --enable-function-subdirs \
        --with-tcsetpgrp \
        --enable-pcre \
        --enable-cap \
        --enable-zsh-secure-free \
        >/dev/null 2>&1 || {
            warn "zsh configure failed"
            return 1
        }
    
    # Compile and install
    make -j$(nproc 2>/dev/null || echo 1) >/dev/null 2>&1 || {
        warn "zsh compilation failed"
        return 1
    }
    
    make install >/dev/null 2>&1 || {
        warn "zsh installation failed"
        return 1
    }
    
    # Add to PATH if needed
    if ! echo "$PATH" | grep -q "$INSTALL_DIR/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Cleanup
    cd "$HOME"
    rm -rf "$INSTALL_DIR/src/zsh-$ZSH_VERSION"*
    
    ok "zsh compiled successfully"
    return 0
}

# Check for zsh, try to install if needed
if ! command -v zsh >/dev/null 2>&1; then
    info "zsh not found, attempting to compile from source..."
    
    # Check for build tools
    for tool in gcc make tar; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            err "Missing build tool: $tool
Please install build essentials first:
  Ubuntu/Debian: sudo apt install build-essential
  CentOS/RHEL: sudo yum groupinstall 'Development Tools'
  Or install zsh directly: sudo apt install zsh"
        fi
    done
    
    # Try to compile ncurses first
    if ! compile_ncurses; then
        err "Failed to compile ncurses. Try installing zsh with package manager:
  Ubuntu/Debian: sudo apt install zsh
  CentOS/RHEL: sudo yum install zsh"
    fi
    
    # Then compile zsh
    if ! compile_zsh; then
        err "Failed to compile zsh. Try installing with package manager:
  Ubuntu/Debian: sudo apt install zsh
  CentOS/RHEL: sudo yum install zsh"
    fi
    
    # Verify zsh installation
    if ! command -v zsh >/dev/null 2>&1; then
        err "zsh installation failed"
    fi
else
    info "zsh found: $(command -v zsh)"
fi

# Clean up any previous Oh My Zsh installation attempts
info "Cleaning up previous installations..."
rm -rf ~/.oh-my-zsh.tmp ~/.p10k.tmp 2>/dev/null || true

# Backup existing config (only once)
if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.backup ]; then
    info "Backing up existing .zshrc"
    cp ~/.zshrc ~/.zshrc.backup
fi

# Handle existing p10k.zsh - rename to backup so install can proceed cleanly
if [ -f ~/.p10k.zsh ]; then
    if [ ! -f ~/.p10k.zsh.backup ]; then
        info "Renaming existing .p10k.zsh to .p10k.zsh.backup"
        mv ~/.p10k.zsh ~/.p10k.zsh.backup
    else
        info "Removing existing .p10k.zsh (backup already exists)"
        rm -f ~/.p10k.zsh
    fi
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

# Install useful plugins
info "Installing useful plugins..."
PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi

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

# Add ~/.local/bin to PATH if it exists
[[ -d ~/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"
EOF

# Install custom p10k config from repository (always overwrite after backup)
info "Installing custom Powerlevel10k configuration..."
if [ -n "$TOOLKIT_BASE_DIR" ] && [ -f "$TOOLKIT_BASE_DIR/zshconfig/p10k.zsh" ]; then
    # Local execution - copy from repository
    cp "$TOOLKIT_BASE_DIR/zshconfig/p10k.zsh" ~/.p10k.zsh
    ok "Installed p10k config from local repository"
else
    # Remote execution - download from GitHub
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/p10k.zsh" > ~/.p10k.zsh && {
            ok "Downloaded p10k config from GitHub"
        } || {
            warn "Failed to download custom p10k config"
        }
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O ~/.p10k.zsh "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/p10k.zsh" && {
            ok "Downloaded p10k config from GitHub"
        } || {
            warn "Failed to download custom p10k config"
        }
    else
        warn "Cannot download custom p10k config - no curl or wget available"
    fi
fi

ok "Zsh setup completed successfully!"

info "Next steps:
1. Set zsh as default shell: chsh -s \$(which zsh)
2. Restart your terminal or run: exec zsh  
3. Run 'p10k configure' to customize your prompt

Recommended: Install a Nerd Font for best experience"
warn "Note: You may need to install a Nerd Font for best experience"