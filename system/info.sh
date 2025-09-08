#!/bin/bash
# Linux Toolkit - System information
# Copyright (c) 2025 Linux Toolkit. MIT License.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

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