#!/bin/bash

# Home Directory Backup Script
# Description: Automated backup of home directory with compression and rotation
# Author: Linux Toolkit

set -euo pipefail

# Configuration
readonly BACKUP_DIR="${BACKUP_DIR:-/backup/home}"
readonly MAX_BACKUPS="${MAX_BACKUPS:-7}"
readonly EXCLUDE_FILE="${HOME}/.backup_exclude"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Log functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create default exclude file if not exists
create_exclude_file() {
    if [[ ! -f "$EXCLUDE_FILE" ]]; then
        log_info "Creating default exclude file..."
        cat > "$EXCLUDE_FILE" << 'EOF'
# Exclude patterns for backup
*.tmp
*.cache
*.log
.cache/
.npm/
.node_modules/
node_modules/
.vscode-server/
.docker/
.local/share/Trash/
Downloads/*.iso
Downloads/*.img
*.swp
*~
.git/
__pycache__/
*.pyc
.vagrant/
VirtualBox VMs/
snap/
EOF
        log_success "Exclude file created: $EXCLUDE_FILE"
    fi
}

# Check disk space
check_disk_space() {
    local required_space=$(du -sb "$HOME" 2>/dev/null | cut -f1)
    local available_space=$(df "$BACKUP_DIR" 2>/dev/null | tail -1 | awk '{print $4}')
    
    # Convert to MB for comparison
    required_space=$((required_space / 1024))
    
    if [[ $available_space -lt $required_space ]]; then
        log_error "Insufficient disk space. Required: ${required_space}KB, Available: ${available_space}KB"
        return 1
    fi
    
    log_info "Disk space check passed"
}

# Perform backup
perform_backup() {
    local backup_file="${BACKUP_DIR}/home_${USER}_${TIMESTAMP}.tar.gz"
    
    log_info "Starting backup of $HOME..."
    log_info "Destination: $backup_file"
    
    # Create backup directory if not exists
    mkdir -p "$BACKUP_DIR"
    
    # Calculate size
    local size=$(du -sh "$HOME" 2>/dev/null | cut -f1)
    log_info "Estimated size: $size"
    
    # Create backup with progress
    if command -v pv &>/dev/null; then
        # Use pv for progress bar if available
        tar czf - \
            --exclude-from="$EXCLUDE_FILE" \
            --exclude-caches \
            --warning=no-file-changed \
            -C "$HOME" . | pv -s $(du -sb "$HOME" | cut -f1) > "$backup_file"
    else
        # Standard tar with verbose output
        tar czf "$backup_file" \
            --exclude-from="$EXCLUDE_FILE" \
            --exclude-caches \
            --warning=no-file-changed \
            -C "$HOME" \
            --checkpoint=1000 \
            --checkpoint-action=echo="Processed %u files..." \
            .
    fi
    
    # Verify backup
    if [[ -f "$backup_file" ]]; then
        local backup_size=$(du -h "$backup_file" | cut -f1)
        log_success "Backup completed successfully!"
        log_info "Backup file: $backup_file"
        log_info "Backup size: $backup_size"
        
        # Test archive integrity
        if tar tzf "$backup_file" &>/dev/null; then
            log_success "Backup integrity verified"
        else
            log_error "Backup integrity check failed!"
            return 1
        fi
    else
        log_error "Backup failed!"
        return 1
    fi
    
    echo "$backup_file"
}

# Rotate old backups
rotate_backups() {
    log_info "Rotating old backups..."
    
    # Count existing backups
    local backup_count=$(find "$BACKUP_DIR" -name "home_${USER}_*.tar.gz" 2>/dev/null | wc -l)
    
    if [[ $backup_count -gt $MAX_BACKUPS ]]; then
        local remove_count=$((backup_count - MAX_BACKUPS))
        log_info "Removing $remove_count old backup(s)..."
        
        # Remove oldest backups
        find "$BACKUP_DIR" -name "home_${USER}_*.tar.gz" -type f -printf '%T+ %p\n' | \
            sort | head -n "$remove_count" | cut -d' ' -f2- | \
            while read -r old_backup; do
                log_info "Removing: $(basename "$old_backup")"
                rm -f "$old_backup"
            done
        
        log_success "Old backups removed"
    else
        log_info "No rotation needed ($backup_count/$MAX_BACKUPS backups)"
    fi
}

# Create backup report
create_report() {
    local backup_file="$1"
    local report_file="${backup_file%.tar.gz}.info"
    
    {
        echo "Backup Report"
        echo "============="
        echo "Date: $(date)"
        echo "User: $USER"
        echo "Hostname: $(hostname)"
        echo "Source: $HOME"
        echo "Destination: $backup_file"
        echo "Size: $(du -h "$backup_file" | cut -f1)"
        echo "Files:"
        tar tzf "$backup_file" | wc -l
        echo ""
        echo "Excluded patterns:"
        cat "$EXCLUDE_FILE"
    } > "$report_file"
    
    log_info "Report saved: $report_file"
}

# Restore backup
restore_backup() {
    local backup_file="$1"
    local restore_dir="${2:-$HOME}"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_warning "This will restore backup to: $restore_dir"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    log_info "Restoring backup..."
    tar xzf "$backup_file" -C "$restore_dir" --checkpoint=1000 --checkpoint-action=echo="Restored %u files..."
    
    log_success "Restore completed!"
}

# List backups
list_backups() {
    log_info "Available backups in $BACKUP_DIR:"
    
    find "$BACKUP_DIR" -name "home_${USER}_*.tar.gz" -type f -printf '%T+ %p\n' 2>/dev/null | \
        sort -r | while read -r date_time backup_path; do
            local size=$(du -h "$backup_path" | cut -f1)
            echo -e "${BLUE}$(basename "$backup_path")${NC} - $size - $date_time"
        done
}

# Main function
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}      Home Directory Backup Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Parse arguments
    case "${1:-backup}" in
        backup)
            create_exclude_file
            check_disk_space || exit 1
            backup_file=$(perform_backup) || exit 1
            rotate_backups
            create_report "$backup_file"
            ;;
        restore)
            restore_backup "${2:-}" "${3:-}"
            ;;
        list)
            list_backups
            ;;
        *)
            echo "Usage: $0 {backup|restore <backup_file> [restore_dir]|list}"
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi