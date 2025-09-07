#!/bin/bash

# Docker Cleanup Script
# Description: Clean up Docker resources (containers, images, volumes, networks)
# Author: Linux Toolkit

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
DRY_RUN=false
FORCE_CLEAN=false
KEEP_DAYS=7

# Log functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Docker installation
check_docker() {
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running or you don't have permission"
        exit 1
    fi
}

# Get Docker disk usage
show_disk_usage() {
    log_info "Current Docker disk usage:"
    docker system df
    echo
}

# Calculate size
calculate_size() {
    local size="$1"
    if [[ "$size" =~ ^[0-9]+$ ]]; then
        # Size in bytes
        echo "$((size / 1024 / 1024)) MB"
    else
        echo "$size"
    fi
}

# Clean stopped containers
clean_containers() {
    log_info "Cleaning stopped containers..."
    
    local containers=$(docker ps -a -q -f status=exited)
    if [[ -z "$containers" ]]; then
        log_info "No stopped containers found"
        return
    fi
    
    local count=$(echo "$containers" | wc -l)
    log_info "Found $count stopped container(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove the following containers:"
        docker ps -a -f status=exited --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
    else
        docker rm $containers
        log_success "Removed $count stopped container(s)"
    fi
}

# Clean dangling images
clean_dangling_images() {
    log_info "Cleaning dangling images..."
    
    local images=$(docker images -q -f dangling=true)
    if [[ -z "$images" ]]; then
        log_info "No dangling images found"
        return
    fi
    
    local count=$(echo "$images" | wc -l)
    local size=$(docker images -f dangling=true --format "{{.Size}}" | awk '{s+=$1} END {print s}')
    
    log_info "Found $count dangling image(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove the following images:"
        docker images -f dangling=true --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        docker rmi $images
        log_success "Removed $count dangling image(s)"
    fi
}

# Clean unused images
clean_unused_images() {
    log_info "Cleaning unused images..."
    
    local images=$(docker images -q | xargs -I {} sh -c 'docker ps -a -q --filter ancestor={} | wc -l | grep -q "^0$" && echo {}' 2>/dev/null | grep -v '^$')
    
    if [[ -z "$images" ]]; then
        log_info "No unused images found"
        return
    fi
    
    local count=$(echo "$images" | wc -l)
    log_info "Found $count unused image(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove unused images"
    else
        if [[ "$FORCE_CLEAN" == true ]]; then
            echo "$images" | xargs docker rmi -f
            log_success "Removed $count unused image(s)"
        else
            log_warning "Use --force to remove unused images"
        fi
    fi
}

# Clean old images
clean_old_images() {
    log_info "Cleaning images older than $KEEP_DAYS days..."
    
    local cutoff_date=$(date -d "$KEEP_DAYS days ago" +%s)
    local old_images=""
    
    while IFS= read -r line; do
        local created=$(echo "$line" | awk '{print $4, $5, $6}')
        local image_id=$(echo "$line" | awk '{print $3}')
        local created_timestamp=$(date -d "$created" +%s 2>/dev/null || echo 0)
        
        if [[ $created_timestamp -lt $cutoff_date && $created_timestamp -ne 0 ]]; then
            old_images="$old_images $image_id"
        fi
    done < <(docker images --format "table {{.Repository}} {{.Tag}} {{.ID}} {{.CreatedAt}}" | tail -n +2)
    
    if [[ -z "$old_images" ]]; then
        log_info "No old images found"
        return
    fi
    
    local count=$(echo "$old_images" | wc -w)
    log_info "Found $count old image(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove old images"
    else
        if [[ "$FORCE_CLEAN" == true ]]; then
            docker rmi $old_images
            log_success "Removed $count old image(s)"
        else
            log_warning "Use --force to remove old images"
        fi
    fi
}

# Clean unused volumes
clean_volumes() {
    log_info "Cleaning unused volumes..."
    
    local volumes=$(docker volume ls -q -f dangling=true)
    if [[ -z "$volumes" ]]; then
        log_info "No unused volumes found"
        return
    fi
    
    local count=$(echo "$volumes" | wc -l)
    log_info "Found $count unused volume(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove the following volumes:"
        docker volume ls -f dangling=true
    else
        docker volume rm $volumes
        log_success "Removed $count unused volume(s)"
    fi
}

# Clean unused networks
clean_networks() {
    log_info "Cleaning unused networks..."
    
    # Get default networks that should not be removed
    local default_networks="bridge host none"
    local networks=$(docker network ls -q --filter "dangling=true" | while read net; do
        local name=$(docker network inspect "$net" --format '{{.Name}}')
        if ! echo "$default_networks" | grep -q "$name"; then
            echo "$net"
        fi
    done)
    
    if [[ -z "$networks" ]]; then
        log_info "No unused networks found"
        return
    fi
    
    local count=$(echo "$networks" | wc -l)
    log_info "Found $count unused network(s)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would remove unused networks"
    else
        docker network rm $networks 2>/dev/null || true
        log_success "Removed unused network(s)"
    fi
}

# Clean build cache
clean_build_cache() {
    log_info "Cleaning build cache..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would clean build cache"
        docker builder du
    else
        docker builder prune -f
        log_success "Cleaned build cache"
    fi
}

# Full system prune
full_system_prune() {
    log_warning "Performing full system prune..."
    log_warning "This will remove:"
    echo "  - All stopped containers"
    echo "  - All unused networks"
    echo "  - All unused images"
    echo "  - All build cache"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN: Would perform full system prune"
    else
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker system prune -af --volumes
            log_success "Full system prune completed"
        else
            log_info "Cancelled"
        fi
    fi
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                log_warning "DRY RUN MODE - No changes will be made"
                ;;
            --force)
                FORCE_CLEAN=true
                ;;
            --days)
                KEEP_DAYS="$2"
                shift
                ;;
            --full)
                full_system_prune
                exit 0
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Show help
show_help() {
    cat << EOF
Docker Cleanup Script

Usage: $0 [OPTIONS]

Options:
    --dry-run    Show what would be cleaned without making changes
    --force      Force removal of unused images
    --days N     Keep images created within last N days (default: 7)
    --full       Perform full system prune (interactive)
    --help       Show this help message

Examples:
    $0                    # Standard cleanup
    $0 --dry-run          # Preview cleanup
    $0 --force --days 30  # Force cleanup, keep 30 days
    $0 --full             # Full system prune
EOF
}

# Main function
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}        Docker Cleanup Script${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    check_docker
    parse_args "$@"
    
    # Show initial usage
    show_disk_usage
    
    # Perform cleanup
    clean_containers
    clean_dangling_images
    clean_unused_images
    clean_old_images
    clean_volumes
    clean_networks
    clean_build_cache
    
    # Show final usage
    echo
    log_success "Cleanup completed!"
    show_disk_usage
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi