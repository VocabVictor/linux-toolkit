#!/bin/bash
# Linux Toolkit - Network speed test
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/network/speed.sh | bash
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

# Install speedtest-cli if not found
install_speedtest_cli() {
    info "Installing speedtest-cli to user directory..."
    
    # Ensure ~/.local/bin exists and is in PATH
    mkdir -p ~/.local/bin
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        info "Adding ~/.local/bin to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Try pip3 installation first (most reliable)
    if command -v pip3 >/dev/null 2>&1; then
        info "Installing speedtest-cli via pip3..."
        if pip3 install --user "speedtest-cli==$SPEEDTEST_VERSION" 2>/dev/null; then
            ok "speedtest-cli $SPEEDTEST_VERSION installed successfully"
            return 0
        else
            warn "Failed to install specific version, trying latest..."
            if pip3 install --user speedtest-cli; then
                ok "speedtest-cli (latest) installed successfully"
                return 0
            fi
        fi
    fi
    
    # Fallback: Direct download method
    warn "pip3 not available or failed, downloading speedtest-cli directly..."
    if smart_download "https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py" "$HOME/.local/bin/speedtest-cli"; then
        chmod +x "$HOME/.local/bin/speedtest-cli"
        ok "speedtest-cli downloaded and installed"
        return 0
    else
        err "Failed to install speedtest-cli. Please install manually:"
        echo "  pip3 install --user speedtest-cli"
        echo "  or download from: https://github.com/sivel/speedtest-cli"
    fi
}

# Check for speedtest-cli, install if not found
if ! command -v speedtest-cli >/dev/null 2>&1; then
    install_speedtest_cli
fi

# Specific version for security
readonly SPEEDTEST_VERSION="2.1.3"

# Run speed test
info "Running network speed test..."
info "Testing connection speed..."

# Use speedtest-cli with error handling
if command -v speedtest-cli >/dev/null 2>&1; then
    speedtest-cli --simple || warn "Speed test completed with warnings"
else
    err "speedtest-cli not found after installation attempt"
fi

ok "Network speed test completed"