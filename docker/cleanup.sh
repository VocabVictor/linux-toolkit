#!/bin/bash
# Linux Toolkit - Docker cleanup
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Detect if running via curl pipe or locally
if [ -z "${BASH_SOURCE[0]:-}" ] || [ "${BASH_SOURCE[0]}" = "" ]; then
    # Running via curl pipe - define functions inline
    err() { echo -e "\033[0;31mERROR:\033[0m $*" >&2; exit 1; }
    warn() { echo -e "\033[0;33mWARN:\033[0m $*" >&2; }
    info() { echo -e "\033[0;34mINFO:\033[0m $*"; }
    ok() { echo -e "\033[0;32mOK:\033[0m $*"; }
    check_cmd() { command -v "$1" >/dev/null 2>&1 || err "$1 not found. Install it first."; }
    confirm() {
        [ ! -t 0 ] && return 0  # Non-interactive, proceed
        echo -n "$1 [y/N]: "
        read -r reply || return 1
        [[ ${reply:-} =~ ^[Yy]$ ]]
    }
else
    # Running locally - source common utilities
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/../lib/common.sh"
fi

check_cmd docker

info "Docker cleanup - removing all unused resources..."
info "This will remove:"
echo "  • All stopped containers"
echo "  • All unused images"
echo "  • All unused volumes"
echo "  • All unused networks"
echo "  • All build cache"
echo

case "${1:-prune}" in
    prune)
        confirm "Remove all unused Docker resources?" || exit 0
        docker system prune -af --volumes
        ok "Docker cleanup completed"
        ;;
    status)
        docker system df
        ;;
    *)
        err "usage: $0 {prune|status}"
        ;;
esac