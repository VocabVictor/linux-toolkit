#!/bin/bash

# System Cleanup Script
# Description: Clean system cache, logs, and temporary files
# Author: Linux Toolkit

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Log functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Calculate size before cleaning
calculate_size() {
    local path="$1"
    if [[ -d "$path" ]]; then
        du -sh "$path" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Clean apt cache (Debian/Ubuntu)
clean_apt_cache() {
    if command -v apt &>/dev/null; then
        log_info "Cleaning APT cache..."
        local before=$(calculate_size "/var/cache/apt")
        apt-get clean
        apt-get autoclean
        apt-get autoremove -y
        local after=$(calculate_size "/var/cache/apt")
        log_success "APT cache cleaned (freed: $before -> $after)"
    fi
}

# Clean yum cache (RHEL/CentOS)
clean_yum_cache() {
    if command -v yum &>/dev/null; then
        log_info "Cleaning YUM cache..."
        yum clean all
        log_success "YUM cache cleaned"
    fi
}

# Clean system logs
clean_logs() {
    log_info "Cleaning system logs..."
    
    # Clean journal logs older than 7 days
    if command -v journalctl &>/dev/null; then
        journalctl --vacuum-time=7d
    fi
    
    # Clean old log files
    find /var/log -type f -name "*.log" -mtime +30 -delete 2>/dev/null || true
    find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
    
    # Truncate large log files
    for log in /var/log/{syslog,messages,kern.log,auth.log}; do
        if [[ -f "$log" ]] && [[ $(stat -c%s "$log") -gt 104857600 ]]; then
            echo "Truncating $log..."
            truncate -s 0 "$log"
        fi
    done
    
    log_success "Logs cleaned"
}

# Clean temporary files
clean_temp() {
    log_info "Cleaning temporary files..."
    
    # Clean /tmp older than 7 days
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
    
    # Clean user cache
    rm -rf /home/*/.cache/thumbnails/* 2>/dev/null || true
    rm -rf /home/*/.cache/pip/* 2>/dev/null || true
    
    log_success "Temporary files cleaned"
}

# Clean Docker (if installed)
clean_docker() {
    if command -v docker &>/dev/null; then
        log_info "Cleaning Docker..."
        docker system prune -af --volumes 2>/dev/null || true
        log_success "Docker cleaned"
    fi
}

# Main cleanup function
main() {
    check_root
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}       System Cleanup Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Get initial disk usage
    local before_usage=$(df -h / | awk 'NR==2 {print $3}')
    
    # Run cleanup tasks
    clean_apt_cache
    clean_yum_cache
    clean_logs
    clean_temp
    clean_docker
    
    # Get final disk usage
    local after_usage=$(df -h / | awk 'NR==2 {print $3}')
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Cleanup Complete!${NC}"
    echo -e "${GREEN}Disk usage: $before_usage -> $after_usage${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi