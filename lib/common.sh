#!/bin/bash
# Linux Toolkit - Common utilities
# Copyright (c) 2025 Linux Toolkit. MIT License.

# Set toolkit base directory - handle both local and remote execution
if [ "${#BASH_SOURCE[@]}" -gt 0 ] && [ -f "${BASH_SOURCE[0]}" ]; then
    # Local execution - calculate relative to common.sh location
    TOOLKIT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
    # Remote execution - functions are standalone, no base directory needed
    TOOLKIT_BASE_DIR=""
fi

set -euo pipefail

# Color support detection
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
    readonly LOG_ERROR="\033[0;31mERROR:\033[0m"
    readonly LOG_WARN="\033[0;33mWARN:\033[0m"
    readonly LOG_INFO="\033[0;34mINFO:\033[0m"
    readonly LOG_OK="\033[0;32mOK:\033[0m"
else
    readonly LOG_ERROR="ERROR:"
    readonly LOG_WARN="WARN:"
    readonly LOG_INFO="INFO:"
    readonly LOG_OK="OK:"
fi

err() {
    echo -e "$LOG_ERROR $*" >&2
    exit 1
}

warn() {
    echo -e "$LOG_WARN $*" >&2
}

info() {
    echo -e "$LOG_INFO $*"
}

ok() {
    echo -e "$LOG_OK $*"
}

check_cmd() {
    [ -z "$1" ] && err "check_cmd: missing command name"
    command -v "$1" >/dev/null 2>&1 || err "$1 not found. Install it first."
}

check_root() {
    [ "$EUID" -eq 0 ] || err "root privileges required"
}

check_file() {
    [ -z "$1" ] && err "check_file: missing file path"
    [ -f "$1" ] || err "file not found: $1"
}

check_dir() {
    [ -z "$1" ] && err "check_dir: missing directory path"
    [ -d "$1" ] || err "directory not found: $1"
}

confirm() {
    local msg="${1:-}"
    [ -z "$msg" ] && err "confirm: missing message"
    
    # Non-interactive mode
    if [ ! -t 0 ] || [ "${CI:-}" = "true" ] || [ "${BATCH:-}" = "true" ]; then
        warn "Non-interactive mode: defaulting to 'no' for: $msg"
        return 1
    fi
    
    echo -n "$msg [y/N]: "
    read -r reply || return 1
    [[ ${reply:-} =~ ^[Yy]$ ]]
}

# Smart download function with timeout
smart_download() {
    local url="$1"
    local output_file="$2"
    local timeout="${3:-30}"
    
    # Direct download with timeout
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --connect-timeout "$timeout" --max-time $((timeout * 2)) "$url" > "$output_file" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$output_file" --timeout="$timeout" "$url" || return 1
    else
        err "Neither curl nor wget available for download"
    fi
}

# Git network configuration functions
setup_git_network() {
    # Store original git configuration
    if command -v git >/dev/null 2>&1; then
        # Save existing configuration
        GIT_ORIG_SSL_VERIFY=$(git config --global --get http.sslVerify 2>/dev/null || echo "")
        GIT_ORIG_PROXY=$(git config --global --get http.proxy 2>/dev/null || echo "")
        
        # Apply network-friendly settings
        git config --global http.sslVerify false
        
        # Try to detect and use system proxy
        if [ -n "${http_proxy:-}" ] || [ -n "${HTTP_PROXY:-}" ]; then
            local proxy="${http_proxy:-${HTTP_PROXY:-}}"
            git config --global http.proxy "$proxy"
            info "Using proxy for git: $proxy"
        fi
        
        info "Git network configuration applied (SSL verification disabled)"
    else
        warn "Git not found, skipping network configuration"
    fi
}

restore_git_network() {
    if command -v git >/dev/null 2>&1; then
        # Restore original SSL verification setting
        if [ -n "${GIT_ORIG_SSL_VERIFY:-}" ]; then
            git config --global http.sslVerify "$GIT_ORIG_SSL_VERIFY"
        else
            git config --global --unset http.sslVerify 2>/dev/null || true
        fi
        
        # Restore original proxy setting
        if [ -n "${GIT_ORIG_PROXY:-}" ]; then
            git config --global http.proxy "$GIT_ORIG_PROXY"
        else
            git config --global --unset http.proxy 2>/dev/null || true
        fi
        
        info "Git network configuration restored"
    fi
}

# Enhanced git clone with network configuration
git_clone_robust() {
    local repo_url="$1"
    local target_dir="$2"
    local depth_arg="${3:---depth=1}"
    
    if [ -z "$repo_url" ] || [ -z "$target_dir" ]; then
        err "git_clone_robust: missing required arguments (repo_url, target_dir)"
    fi
    
    # Setup network configuration
    setup_git_network
    
    # Attempt clone with retry logic
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if git clone $depth_arg "$repo_url" "$target_dir" 2>/dev/null; then
            ok "Successfully cloned $repo_url"
            restore_git_network
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            warn "Clone attempt $retry_count failed, retrying..."
            sleep 2
        fi
    done
    
    # All retries failed
    restore_git_network
    err "Failed to clone $repo_url after $max_retries attempts"
}

# Import local script
import_script() {
    local script_path="$1"
    source "$TOOLKIT_BASE_DIR/$script_path"
}