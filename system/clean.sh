#!/bin/bash
# Linux Toolkit - System cleanup
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Source functions - local or standalone mode
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    # Local execution - use common.sh
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/../lib/common.sh"
else
    # Standalone execution - minimal inline functions
    err() { echo -e "\033[0;31mERROR:\033[0m $*" >&2; exit 1; }
    warn() { echo -e "\033[0;33mWARN:\033[0m $*" >&2; }
    info() { echo -e "\033[0;34mINFO:\033[0m $*"; }
    ok() { echo -e "\033[0;32mOK:\033[0m $*"; }
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
[ -d ~/.cache ] && find ~/.cache -type f -atime +7 -exec rm -f {} + 2>/dev/null || true
[ -d ~/.thumbnails ] && rm -rf ~/.thumbnails/* 2>/dev/null

# Clean temporary files (safer)
info "Cleaning temporary files..."
# Only clean files older than 7 days and avoid system-critical temp files
find /tmp -type f -atime +7 ! -path "/tmp/systemd-*" ! -path "/tmp/.X*" -exec rm -f {} + 2>/dev/null || true

# Clean logs (only old ones, more conservative)
if [ "$EUID" -eq 0 ]; then
    info "Cleaning old log files..."
    # Only clean rotated logs and very old main logs
    find /var/log -type f -name "*.log.*" -mtime +7 -exec rm -f {} + 2>/dev/null || true
    find /var/log -type f -name "*.log" -mtime +90 ! -name "kern.log" ! -name "syslog" -exec rm -f {} + 2>/dev/null || true
else
    info "Skipping system log cleanup (requires root)"
fi

ok "System cleanup completed"