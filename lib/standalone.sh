#!/bin/bash
# Minimal standalone functions for remote execution
# This file is meant to be embedded in scripts that support curl pipe execution

# Core functions - minimal implementation for standalone mode
err() { echo -e "\033[0;31mERROR:\033[0m $*" >&2; exit 1; }
warn() { echo -e "\033[0;33mWARN:\033[0m $*" >&2; }
info() { echo -e "\033[0;34mINFO:\033[0m $*"; }
ok() { echo -e "\033[0;32mOK:\033[0m $*"; }
check_cmd() { command -v "$1" >/dev/null 2>&1 || err "$1 not found. Install it first."; }

# Minimal download function
smart_download() {
    local url="$1"
    local output_file="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" > "$output_file" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$output_file" "$url" || return 1
    else
        err "Neither curl nor wget available"
    fi
}

# Minimal confirm function for interactive prompts
confirm() {
    [ ! -t 0 ] && return 0  # Non-interactive, proceed
    echo -n "$1 [y/N]: "
    read -r reply || return 1
    [[ ${reply:-} =~ ^[Yy]$ ]]
}