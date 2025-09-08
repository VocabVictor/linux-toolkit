#!/bin/bash
# Linux Toolkit - Zsh setup (standalone capable)
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Source functions - download if needed
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
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

info "Installing Zsh + Oh My Zsh setup"

# Function to compile ncurses locally
install_ncurses_local() {
    local INSTALL_DIR="$1"
    local NCURSES_VERSION="6.4"
    local NCURSES_DIR="$INSTALL_DIR/src/ncurses-$NCURSES_VERSION"
    
    info "Downloading ncurses $NCURSES_VERSION..."
    cd "$INSTALL_DIR/src"
    
    if ! smart_download "https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VERSION.tar.gz" "ncurses-$NCURSES_VERSION.tar.gz"; then
        warn "Failed to download ncurses"
        return 1
    fi
    
    tar -xf "ncurses-$NCURSES_VERSION.tar.gz" || return 1
    cd "$NCURSES_DIR"
    
    info "Configuring ncurses..."
    # Export ALL necessary flags to ensure they persist through the entire build process
    export CFLAGS="-fPIC -O2"
    export CPPFLAGS="-I$INSTALL_DIR/include"
    export LDFLAGS="-L$INSTALL_DIR/lib"
    
    # Configure with shared libraries ONLY and skip C++ to avoid linking issues
    ./configure \
        --prefix="$INSTALL_DIR" \
        --enable-shared \
        --disable-static \
        --enable-widec \
        --without-debug \
        --without-ada \
        --without-cxx \
        --without-cxx-binding \
        --enable-overwrite \
        --with-shared \
        --enable-pc-files \
        --with-pkg-config-libdir="$INSTALL_DIR/lib/pkgconfig" \
        --with-termlib \
        >/dev/null 2>&1 || return 1
    
    info "Compiling ncurses (this may take a few minutes)..."
    # Force PIC compilation for all objects, only build libs and headers (not programs/C++)
    make -j$(nproc 2>/dev/null || echo 1) CFLAGS="-fPIC -O2" libs >/dev/null 2>&1 || return 1
    
    info "Installing ncurses to $INSTALL_DIR..."
    make install >/dev/null 2>&1 || return 1
    
    # CRITICAL: Remove ALL static libraries to force dynamic linking
    info "Removing static libraries to ensure dynamic linking..."
    rm -f "$INSTALL_DIR/lib"/*.a 2>/dev/null
    
    # Update PKG_CONFIG_PATH and LD_LIBRARY_PATH
    export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export LD_LIBRARY_PATH="$INSTALL_DIR/lib:${LD_LIBRARY_PATH:-}"
    export CPPFLAGS="-I$INSTALL_DIR/include ${CPPFLAGS:-}"
    export LDFLAGS="-L$INSTALL_DIR/lib -Wl,-rpath,$INSTALL_DIR/lib ${LDFLAGS:-}"
    
    # Clean up
    cd "$INSTALL_DIR/src"
    rm -rf "$NCURSES_DIR" "ncurses-$NCURSES_VERSION.tar.gz"
    
    return 0
}

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
    
    # Check for required build tools
    local missing_tools=()
    for tool in gcc make; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    # Check for ncurses development headers - try multiple locations
    has_ncurses=false
    for ncurses_path in \
        /usr/include/ncurses.h \
        /usr/include/ncursesw/ncurses.h \
        /usr/include/ncurses/ncurses.h \
        /usr/local/include/ncurses.h \
        /usr/local/include/ncursesw/ncurses.h \
        "$HOME/.local/include/ncurses.h" \
        "$HOME/.local/include/ncursesw/ncurses.h"; do
        if [ -f "$ncurses_path" ]; then
            has_ncurses=true
            break
        fi
    done
    
    # Also check if pkg-config can find ncurses
    if pkg-config --exists ncurses 2>/dev/null || pkg-config --exists ncursesw 2>/dev/null; then
        has_ncurses=true
    fi
    
    if [ "$has_ncurses" = false ]; then
        missing_tools+=("ncurses-dev")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        # Check if we only miss ncurses but have gcc/make
        has_build_tools=true
        for tool in gcc make; do
            if ! command -v "$tool" >/dev/null 2>&1; then
                has_build_tools=false
                break
            fi
        done
        
        if [ "$has_build_tools" = true ] && [[ " ${missing_tools[*]} " == *" ncurses-dev "* ]]; then
            # We have build tools but missing ncurses - try to compile it
            warn "Missing ncurses development headers. Attempting to compile ncurses locally..."
            if install_ncurses_local "$INSTALL_DIR"; then
                info "Ncurses compiled successfully. Continuing with zsh compilation..."
            else
                warn "Failed to compile ncurses. Proceeding anyway - zsh configure will use fallback."
            fi
        else
            # Missing critical build tools
            warn "Missing essential build dependencies: ${missing_tools[*]}"
            warn ""
            warn "For server environments, please ask your administrator to install:"
            if command -v apt-get >/dev/null 2>&1; then
                warn "  sudo apt-get install build-essential libncurses5-dev libncursesw5-dev"
            elif command -v yum >/dev/null 2>&1; then
                warn "  sudo yum install gcc make ncurses-devel"
            elif command -v dnf >/dev/null 2>&1; then
                warn "  sudo dnf install gcc make ncurses-devel"
            else
                warn "  gcc, make, and ncurses development headers"
            fi
            warn ""
            warn "Or if you have personal server access:"
            if command -v apt-get >/dev/null 2>&1; then
                warn "  sudo apt-get install zsh (faster)"
            elif command -v yum >/dev/null 2>&1; then
                warn "  sudo yum install zsh (faster)"
            elif command -v dnf >/dev/null 2>&1; then
                warn "  sudo dnf install zsh (faster)"
            fi
            err "Cannot compile without build tools. Install gcc/make first."
        fi
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
    
    # Configure and compile (use local ncurses if available)
    info "Configuring zsh build..."
    
    # Set up environment for local ncurses if it exists (ONLY check for shared library)
    if [ -f "$INSTALL_DIR/lib/libncursesw.so" ]; then
        info "Using locally compiled ncurses (shared library)..."
        export PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
        export LD_LIBRARY_PATH="$INSTALL_DIR/lib:${LD_LIBRARY_PATH:-}"
        export CPPFLAGS="-I$INSTALL_DIR/include ${CPPFLAGS:-}"
        export LDFLAGS="-L$INSTALL_DIR/lib -Wl,-rpath,$INSTALL_DIR/lib ${LDFLAGS:-}"
        # Ensure zsh uses shared libraries
        export LIBS="-lncursesw"
    fi
    
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

# Download p10k configuration if not exists
if [ ! -f ~/.p10k.zsh ]; then
    info "Downloading Powerlevel10k configuration..."
    smart_download "https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/p10k.zsh" ~/.p10k.zsh || {
        warn "Failed to download p10k.zsh configuration, you can configure it manually later"
    }
else
    info "Powerlevel10k configuration already exists"
fi

ok "Zsh setup completed successfully!"
echo
info "Next steps:"
echo "1. Set zsh as default shell: chsh -s \$(which zsh)"
echo "2. Restart your terminal or run: exec zsh"
echo "3. Follow the Powerlevel10k configuration wizard"
echo
warn "Note: You may need to install a Nerd Font for best experience"
echo "      Recommended: https://github.com/romkatv/powerlevel10k#fonts"