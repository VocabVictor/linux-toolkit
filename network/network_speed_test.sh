#!/bin/bash

# Network Speed Test Script
# Description: Test network speed and connectivity
# Author: Linux Toolkit

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly TEST_SERVERS=(
    "1.1.1.1"           # Cloudflare
    "8.8.8.8"           # Google
    "223.5.5.5"         # AliDNS
    "114.114.114.114"   # 114 DNS
)

readonly DOWNLOAD_URLS=(
    "http://speedtest.tele2.net/10MB.zip"
    "http://speed.hetzner.de/10MB.bin"
    "http://mirror.tuna.tsinghua.edu.cn/speedtest/10MB.bin"
)

# Log functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Test DNS resolution
test_dns() {
    log_info "Testing DNS resolution..."
    
    local domains=("google.com" "github.com" "baidu.com")
    
    for domain in "${domains[@]}"; do
        if host "$domain" &>/dev/null; then
            local ip=$(host "$domain" | grep "has address" | head -1 | awk '{print $4}')
            echo -e "  ${GREEN}✓${NC} $domain → $ip"
        else
            echo -e "  ${RED}✗${NC} $domain"
        fi
    done
}

# Test ping latency
test_ping() {
    log_info "Testing ping latency..."
    
    for server in "${TEST_SERVERS[@]}"; do
        if ping -c 4 -W 2 "$server" &>/dev/null; then
            local avg=$(ping -c 4 -W 2 "$server" | tail -1 | awk -F '/' '{print $5}')
            local loss=$(ping -c 4 -W 2 "$server" | grep -oP '\d+(?=% packet loss)')
            echo -e "  ${GREEN}✓${NC} $server: ${avg}ms (${loss}% loss)"
        else
            echo -e "  ${RED}✗${NC} $server: unreachable"
        fi
    done
}

# Test download speed
test_download() {
    log_info "Testing download speed..."
    
    for url in "${DOWNLOAD_URLS[@]}"; do
        local domain=$(echo "$url" | awk -F/ '{print $3}')
        
        # Test with timeout
        if timeout 10 curl -s -w "" "$url" -o /dev/null 2>/dev/null; then
            local speed=$(curl -s -w "%{speed_download}" "$url" -o /dev/null | awk '{printf "%.2f", $1/1024/1024}')
            echo -e "  ${GREEN}✓${NC} $domain: ${speed} MB/s"
        else
            echo -e "  ${YELLOW}!${NC} $domain: timeout or unavailable"
        fi
    done
}

# Test port connectivity
test_ports() {
    log_info "Testing common ports..."
    
    local ports=(
        "google.com:80:HTTP"
        "google.com:443:HTTPS"
        "github.com:22:SSH"
        "1.1.1.1:53:DNS"
    )
    
    for port_info in "${ports[@]}"; do
        IFS=':' read -r host port service <<< "$port_info"
        
        if timeout 2 nc -zv "$host" "$port" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $service ($host:$port)"
        else
            echo -e "  ${RED}✗${NC} $service ($host:$port)"
        fi
    done
}

# Get network interfaces
show_interfaces() {
    log_info "Network interfaces:"
    
    ip -br addr | while read -r iface state addresses; do
        if [[ "$state" == "UP" ]]; then
            echo -e "  ${GREEN}✓${NC} $iface: $addresses"
        elif [[ "$state" == "DOWN" ]]; then
            echo -e "  ${YELLOW}!${NC} $iface: DOWN"
        fi
    done
}

# Trace route
trace_route() {
    local target="${1:-8.8.8.8}"
    
    log_info "Tracing route to $target..."
    
    if command -v traceroute &>/dev/null; then
        traceroute -n -m 15 "$target" 2>/dev/null | head -20
    elif command -v tracepath &>/dev/null; then
        tracepath -n "$target" 2>/dev/null | head -20
    else
        log_warning "traceroute/tracepath not installed"
    fi
}

# Speed test using speedtest-cli
speedtest_cli() {
    if ! command -v speedtest-cli &>/dev/null; then
        log_warning "speedtest-cli not installed"
        read -p "Install speedtest-cli? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v pip3 &>/dev/null; then
                pip3 install speedtest-cli --user
            else
                log_error "pip3 not found, cannot install speedtest-cli"
                return
            fi
        else
            return
        fi
    fi
    
    log_info "Running speedtest-cli..."
    speedtest-cli --simple
}

# Network statistics
show_statistics() {
    log_info "Network statistics:"
    
    # Show transfer rates
    if [[ -f /proc/net/dev ]]; then
        echo -e "\n${BLUE}Interface statistics:${NC}"
        awk 'NR>2 {print $1, "RX:", $2/1024/1024 "MB", "TX:", $10/1024/1024 "MB"}' /proc/net/dev | column -t
    fi
    
    # Show connections
    echo -e "\n${BLUE}Active connections:${NC}"
    ss -tun | tail -n +2 | wc -l | xargs echo "  Total:"
    ss -tun state established | tail -n +2 | wc -l | xargs echo "  Established:"
    ss -tun state listening | tail -n +2 | wc -l | xargs echo "  Listening:"
}

# Generate report
generate_report() {
    local report_file="/tmp/network_test_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Network Test Report"
        echo "=================="
        echo "Date: $(date)"
        echo "Hostname: $(hostname)"
        echo ""
        
        show_interfaces
        echo ""
        test_dns
        echo ""
        test_ping
        echo ""
        test_ports
        echo ""
        test_download
        echo ""
        show_statistics
    } | tee "$report_file"
    
    log_success "Report saved to: $report_file"
}

# Main function
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}       Network Speed Test Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    case "${1:-all}" in
        dns)
            test_dns
            ;;
        ping)
            test_ping
            ;;
        download)
            test_download
            ;;
        ports)
            test_ports
            ;;
        trace)
            trace_route "${2:-}"
            ;;
        speed)
            speedtest_cli
            ;;
        stats)
            show_statistics
            ;;
        report)
            generate_report
            ;;
        all)
            show_interfaces
            echo
            test_dns
            echo
            test_ping
            echo
            test_ports
            echo
            test_download
            echo
            show_statistics
            ;;
        *)
            echo "Usage: $0 {all|dns|ping|download|ports|trace [target]|speed|stats|report}"
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi