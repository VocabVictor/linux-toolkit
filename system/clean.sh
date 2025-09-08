#!/bin/bash
# Linux Toolkit - System cleanup (standalone capable)
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Smart download function
smart_download() {
    local url="$1"
    local output_file="$2"
    local use_proxy="${GITHUB_PROXY:-true}"
    
    if [ "$use_proxy" = "true" ] && [[ "$url" == *"raw.githubusercontent.com"* ]]; then
        local proxy_url="https://gh-proxy.com/$url"
        echo "INFO: Using GitHub proxy for better connectivity..."
        if curl -fsSL --connect-timeout 10 "$proxy_url" > "$output_file" 2>/dev/null; then
            return 0
        else
            echo "WARN: Proxy failed, trying direct connection..." >&2
        fi
    fi
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

info "Starting system cleanup"

# Clean package cache
if command -v apt >/dev/null; then
    info "Cleaning apt cache..."
    sudo apt autoclean >/dev/null 2>&1 || warn "apt autoclean failed"
    sudo apt autoremove -y >/dev/null 2>&1 || warn "apt autoremove failed"
elif command -v yum >/dev/null; then
    info "Cleaning yum cache..."
    sudo yum clean all >/dev/null 2>&1 || warn "yum clean failed"
fi

# Clean user caches
info "Cleaning user caches..."
[ -d ~/.cache ] && find ~/.cache -type f -atime +7 -delete 2>/dev/null
[ -d ~/.thumbnails ] && rm -rf ~/.thumbnails/* 2>/dev/null

# Clean temporary files (safer)
info "Cleaning temporary files..."
# Only clean files older than 7 days and avoid system-critical temp files
find /tmp -type f -atime +7 -not -path "/tmp/systemd-*" -not -path "/tmp/.X*" -delete 2>/dev/null || true

# Clean logs (only old ones, more conservative)
if [ "$EUID" -eq 0 ]; then
    info "Cleaning old log files..."
    # Only clean rotated logs and very old main logs
    find /var/log -type f -name "*.log.*" -mtime +7 -delete 2>/dev/null || true
    find /var/log -type f -name "*.log" -mtime +90 -not -name "kern.log" -not -name "syslog" -delete 2>/dev/null || true
else
    info "Skipping system log cleanup (requires root)"
fi

ok "System cleanup completed"