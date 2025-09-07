#!/bin/bash
# Linux Toolkit - Common utilities
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Dynamic import - can be sourced remotely
if [[ "${BASH_SOURCE[0]}" == *"http"* ]] || [[ ! -f "${BASH_SOURCE[0]}" ]]; then
    TOOLKIT_REMOTE=true
    TOOLKIT_BASE_URL="https://raw.githubusercontent.com/user/linux-toolkit/main"
else
    TOOLKIT_REMOTE=false
    TOOLKIT_BASE_URL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

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

# Smart download function with GitHub proxy support
smart_download() {
    local url="$1"
    local output_file="$2"
    local use_proxy="${GITHUB_PROXY:-true}"
    
    # Add GitHub proxy for mainland China users
    if [ "$use_proxy" = "true" ] && [[ "$url" == *"raw.githubusercontent.com"* ]]; then
        local proxy_url="https://gh-proxy.com/$url"
        info "Using GitHub proxy for better connectivity..."
        if curl -fsSL --connect-timeout 10 "$proxy_url" > "$output_file" 2>/dev/null; then
            return 0
        else
            warn "Proxy failed, trying direct connection..."
        fi
    fi
    
    # Fallback to direct download
    curl -fsSL "$url" > "$output_file" || return 1
}

# Enhanced import function with smart download
import_remote() {
    local script_path="$1"
    local temp_file="/tmp/toolkit_$(basename "$script_path")"
    
    if [ "$TOOLKIT_REMOTE" = "true" ]; then
        smart_download "$TOOLKIT_BASE_URL/$script_path" "$temp_file" || err "Failed to download $script_path"
        source "$temp_file"
        rm -f "$temp_file"
    else
        source "$TOOLKIT_BASE_URL/$script_path"
    fi
}