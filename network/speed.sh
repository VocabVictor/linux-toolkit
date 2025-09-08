#!/bin/bash
# Linux Toolkit - Network speed test
# Copyright (c) 2025 Linux Toolkit. MIT License.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

check_cmd speedtest-cli

# Specific version for security
readonly SPEEDTEST_VERSION="2.1.3"

case "${1:-test}" in
    test)
        info "Running network speed test..."
        speedtest-cli --simple
        ;;
    install)
        info "Installing speedtest-cli version $SPEEDTEST_VERSION..."
        if pip3 install --user "speedtest-cli==$SPEEDTEST_VERSION"; then
            ok "speedtest-cli $SPEEDTEST_VERSION installed"
        else
            warn "Failed to install specific version, trying latest..."
            pip3 install --user speedtest-cli
            warn "Installed latest version (version not pinned)"
        fi
        ;;
    *)
        err "usage: $0 {test|install}"
        ;;
esac