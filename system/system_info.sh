#!/bin/bash

# System Information Collector
# Description: Collect and display comprehensive system information
# Author: Linux Toolkit

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Section header
print_section() {
    echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

# System basic info
system_info() {
    print_section "SYSTEM INFORMATION"
    echo -e "${BLUE}Hostname:${NC} $(hostname)"
    echo -e "${BLUE}Kernel:${NC} $(uname -r)"
    echo -e "${BLUE}OS:${NC} $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${BLUE}Architecture:${NC} $(uname -m)"
    echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
    echo -e "${BLUE}Current Time:${NC} $(date)"
}

# CPU information
cpu_info() {
    print_section "CPU INFORMATION"
    echo -e "${BLUE}Model:${NC} $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo -e "${BLUE}Cores:${NC} $(nproc)"
    echo -e "${BLUE}Frequency:${NC} $(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs) MHz"
    echo -e "${BLUE}Cache:${NC} $(grep "cache size" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo -e "${BLUE}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
}

# Memory information
memory_info() {
    print_section "MEMORY INFORMATION"
    free -h | grep -E "^Mem|^Swap" | while read line; do
        echo -e "${BLUE}$line${NC}"
    done
    
    # Memory usage percentage
    local mem_used=$(free | grep Mem | awk '{print ($2-$7)/$2 * 100.0}')
    printf "${BLUE}Memory Usage:${NC} %.1f%%\n" $mem_used
}

# Disk information
disk_info() {
    print_section "DISK INFORMATION"
    df -h | grep -E "^/dev/" | while read line; do
        echo -e "${BLUE}$line${NC}"
    done
    
    # Disk I/O stats
    if command -v iostat &>/dev/null; then
        echo -e "\n${YELLOW}Disk I/O Statistics:${NC}"
        iostat -x 1 2 | tail -n +4
    fi
}

# Network information
network_info() {
    print_section "NETWORK INFORMATION"
    
    # Network interfaces
    ip -br addr | while read iface state addresses; do
        if [[ "$state" == "UP" ]]; then
            echo -e "${BLUE}Interface:${NC} $iface ${GREEN}[$state]${NC} $addresses"
        fi
    done
    
    # Default gateway
    echo -e "${BLUE}Default Gateway:${NC} $(ip route | grep default | awk '{print $3}')"
    
    # DNS servers
    echo -e "${BLUE}DNS Servers:${NC}"
    grep "nameserver" /etc/resolv.conf | awk '{print "  " $2}'
    
    # Open ports
    echo -e "${BLUE}Listening Ports:${NC}"
    ss -tuln | grep LISTEN | awk '{print "  " $5}' | sort -u
}

# Process information
process_info() {
    print_section "TOP PROCESSES"
    
    echo -e "${YELLOW}By CPU Usage:${NC}"
    ps aux --sort=-%cpu | head -6 | awk '{printf "  %-10s %5s%% %s\n", $1, $3, $11}'
    
    echo -e "\n${YELLOW}By Memory Usage:${NC}"
    ps aux --sort=-%mem | head -6 | awk '{printf "  %-10s %5s%% %s\n", $1, $4, $11}'
}

# Service status
service_info() {
    print_section "SERVICE STATUS"
    
    # Check important services
    local services=("ssh" "docker" "nginx" "apache2" "mysql" "postgresql" "redis")
    
    for service in "${services[@]}"; do
        if systemctl list-units --full -all | grep -Fq "$service.service"; then
            local status=$(systemctl is-active "$service" 2>/dev/null || echo "unknown")
            if [[ "$status" == "active" ]]; then
                echo -e "${BLUE}$service:${NC} ${GREEN}●${NC} $status"
            else
                echo -e "${BLUE}$service:${NC} ${RED}●${NC} $status"
            fi
        fi
    done
}

# User information
user_info() {
    print_section "USER INFORMATION"
    echo -e "${BLUE}Current User:${NC} $USER"
    echo -e "${BLUE}User ID:${NC} $(id -u)"
    echo -e "${BLUE}Groups:${NC} $(groups)"
    echo -e "${BLUE}Logged In Users:${NC}"
    who | while read line; do
        echo "  $line"
    done
}

# Generate report
generate_report() {
    local report_file="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        system_info
        cpu_info
        memory_info
        disk_info
        network_info
        process_info
        service_info
        user_info
    } | tee "$report_file"
    
    echo -e "\n${GREEN}Report saved to: $report_file${NC}"
}

# Main function
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}     System Information Collector${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    if [[ "${1:-}" == "--report" ]]; then
        generate_report
    else
        system_info
        cpu_info
        memory_info
        disk_info
        network_info
        process_info
        service_info
        user_info
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi