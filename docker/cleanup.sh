#!/bin/bash
# Linux Toolkit - Docker cleanup
# Copyright (c) 2025 Linux Toolkit. MIT License.

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

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