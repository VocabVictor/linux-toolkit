#!/bin/bash
# Linux Toolkit - System information
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/info.sh | bash
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

info "System Information"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

info "CPU Information"
grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs
echo "Cores: $(nproc)"

info "Memory Information"
free -h

info "Disk Usage"
df -h | grep -vE '^tmpfs|^udev'

info "Top Processes"
ps aux --sort=-%cpu | head -10