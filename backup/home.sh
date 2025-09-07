#!/bin/bash
# Linux Toolkit - Home directory backup
# Copyright (c) 2025 Linux Toolkit. MIT License.

source "$(dirname "$0")/../lib/common.sh"

readonly BDIR="${BACKUP_DIR:-/backup/home}"
readonly MAX="${MAX_BACKUPS:-7}"
readonly EXCL="${HOME}/.backup_exclude"

init_exclude() {
    [[ -f "$EXCL" ]] && return
    cat > "$EXCL" << 'EOF'
*.tmp
*.cache  
*.log
.cache/
.npm/
node_modules/
.vscode-server/
.docker/
.local/share/Trash/
*.swp
*~
.git/
__pycache__/
*.pyc
EOF
}

backup() {
    local file="${BDIR}/home_$(date +%Y%m%d_%H%M%S).tar.gz"
    mkdir -p "$BDIR" || err "failed to create backup directory"
    
    # Create backup with proper error handling
    if ! tar czf "$file" --exclude-from="$EXCL" -C "$HOME" . 2>&1; then
        rm -f "$file"  # cleanup partial file
        err "backup failed"
    fi
    
    # Verify archive integrity
    if ! tar tzf "$file" >/dev/null 2>&1; then
        rm -f "$file"  # cleanup corrupted file
        err "archive corrupted"
    fi
    
    ok "backup: $file ($(du -h "$file" | cut -f1))"
    
    # Cleanup old backups (simplified)
    local count=$(find "$BDIR" -name "home_*.tar.gz" -type f | wc -l)
    if [ "$count" -gt "$MAX" ]; then
        # Remove oldest files
        find "$BDIR" -name "home_*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | head -n $((count - MAX)) | cut -d' ' -f2- | xargs rm -f
        info "removed $((count - MAX)) old backups"
    fi
}

case "${1:-backup}" in
    backup) init_exclude; backup ;;
    list) find "$BDIR" -name "home_*.tar.gz" -printf '%TY-%Tm-%Td %TH:%TM %s %p\n' | sort -r ;;
    *) err "usage: $0 {backup|list}" ;;
esac