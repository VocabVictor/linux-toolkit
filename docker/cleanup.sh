#!/bin/bash
# Linux Toolkit - Docker cleanup
# Usage: curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash
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