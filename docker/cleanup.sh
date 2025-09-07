#!/bin/bash
# Linux Toolkit - Docker cleanup (standalone capable)
# Usage: curl -fsSL https://raw.githubusercontent.com/user/linux-toolkit/main/docker/cleanup.sh | bash
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Smart download function
smart_download() {
    local url="$1"
    local output_file="$2"
    local use_proxy="${GITHUB_PROXY:-true}"
    
    if [ "$use_proxy" = "true" ] && [[ "$url" == *"raw.githubusercontent.com"* ]]; then
        local proxy_url="https://gh-proxy.com/$url"
        echo "INFO: Using GitHub proxy for better connectivity..."
        if curl -fsSL --connect-timeout 10 "$proxy_url" > "$output_file" 2>/dev/null; then
            return 0
        else
            echo "WARN: Proxy failed, trying direct connection..." >&2
        fi
    fi
    curl -fsSL "$url" > "$output_file" || return 1
}

# Auto-detect if running standalone or locally
if [[ "${BASH_SOURCE[0]}" == *"http"* ]] || [[ ! -f "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh" ]]; then
    # Standalone mode - download common.sh
    echo "INFO: Running in standalone mode, downloading dependencies..."
    TEMP_COMMON="/tmp/toolkit_common_$(date +%s).sh"
    smart_download "https://raw.githubusercontent.com/user/linux-toolkit/main/lib/common.sh" "$TEMP_COMMON" || {
        echo "ERROR: Failed to download common utilities" >&2
        exit 1
    }
    source "$TEMP_COMMON"
    rm -f "$TEMP_COMMON"
else
    # Local mode
    source "$(dirname "$0")/../lib/common.sh"
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