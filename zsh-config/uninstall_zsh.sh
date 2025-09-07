#!/bin/bash

# Zsh Configuration Uninstaller
# Version: 1.0
# Description: Safely remove Oh My Zsh and restore previous shell configuration

set -euo pipefail

# 颜色输出
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 错误处理
error_exit() {
    log_error "$1"
    exit 1
}

# 显示卸载选项
show_uninstall_options() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    Zsh 配置卸载工具${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo "选择卸载选项："
    echo "1) 完全卸载 (删除 Oh My Zsh 和所有配置)"
    echo "2) 部分卸载 (仅删除 Oh My Zsh，保留配置文件)"
    echo "3) 恢复默认 (恢复到系统默认 shell)"
    echo "4) 备份配置 (仅备份当前配置)"
    echo "5) 取消"
    echo
}

# 检查 zsh 安装状态
check_zsh_status() {
    log_info "检查当前 Zsh 配置状态..."
    
    # 检查 Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "✓ 发现 Oh My Zsh 安装"
    else
        log_warning "未发现 Oh My Zsh 安装"
    fi
    
    # 检查配置文件
    if [[ -f "$HOME/.zshrc" ]]; then
        log_info "✓ 发现 .zshrc 配置文件"
    else
        log_warning "未发现 .zshrc 配置文件"
    fi
    
    # 检查 Powerlevel10k
    if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        log_info "✓ 发现 Powerlevel10k 主题"
    fi
    
    # 检查当前默认 shell
    local current_shell=$(basename "$SHELL")
    log_info "当前默认 shell: $current_shell"
    
    # 检查备份
    if [[ -f "$HOME/.zsh_backup_location" ]]; then
        local backup_dir=$(cat "$HOME/.zsh_backup_location")
        if [[ -d "$backup_dir" ]]; then
            log_info "✓ 发现配置备份: $backup_dir"
        fi
    fi
}

# 创建备份
create_backup() {
    log_info "创建当前配置备份..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.config/zsh_uninstall_backup_$timestamp"
    
    mkdir -p "$backup_dir"
    
    # 备份配置文件
    for file in ~/.zshrc ~/.p10k.zsh ~/.zsh_history; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            log_success "已备份: $(basename "$file")"
        fi
    done
    
    # 备份 Oh My Zsh 目录
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        cp -r "$HOME/.oh-my-zsh" "$backup_dir/"
        log_success "已备份: Oh My Zsh 目录"
    fi
    
    echo "$backup_dir" > "$HOME/.zsh_uninstall_backup_location"
    log_success "备份完成: $backup_dir"
}

# 恢复从备份
restore_from_backup() {
    local backup_file="$HOME/.zsh_backup_location"
    
    if [[ ! -f "$backup_file" ]]; then
        log_warning "未找到备份位置信息"
        return 1
    fi
    
    local backup_dir=$(cat "$backup_file")
    
    if [[ ! -d "$backup_dir" ]]; then
        log_warning "备份目录不存在: $backup_dir"
        return 1
    fi
    
    log_info "从备份恢复配置: $backup_dir"
    
    # 恢复配置文件
    for file in "$backup_dir"/.zshrc "$backup_dir"/.p10k.zsh; do
        if [[ -f "$file" ]]; then
            cp "$file" "$HOME/"
            log_success "已恢复: $(basename "$file")"
        fi
    done
    
    # 恢复 Oh My Zsh
    if [[ -d "$backup_dir/.oh-my-zsh" ]]; then
        rm -rf "$HOME/.oh-my-zsh"
        cp -r "$backup_dir/.oh-my-zsh" "$HOME/"
        log_success "已恢复: Oh My Zsh 目录"
    fi
    
    log_success "配置恢复完成"
}

# 删除 Oh My Zsh
remove_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "删除 Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        log_success "Oh My Zsh 已删除"
    else
        log_warning "Oh My Zsh 目录不存在"
    fi
}

# 删除配置文件
remove_config_files() {
    local files=(
        "$HOME/.zshrc"
        "$HOME/.p10k.zsh"
        "$HOME/.zcompdump"
        "$HOME/.zcompdump-"*
    )
    
    log_info "删除 Zsh 配置文件..."
    
    for file in "${files[@]}"; do
        if [[ -f "$file" || -L "$file" ]]; then
            rm -f "$file"
            log_success "已删除: $(basename "$file")"
        fi
    done
}

# 删除插件和主题
remove_custom_plugins() {
    local custom_dir="$HOME/.oh-my-zsh/custom"
    
    if [[ -d "$custom_dir" ]]; then
        log_info "删除自定义插件和主题..."
        
        # 删除插件
        if [[ -d "$custom_dir/plugins" ]]; then
            rm -rf "$custom_dir/plugins"
            log_success "已删除: 自定义插件"
        fi
        
        # 删除主题
        if [[ -d "$custom_dir/themes" ]]; then
            rm -rf "$custom_dir/themes"
            log_success "已删除: 自定义主题"
        fi
    fi
}

# 恢复默认 shell
restore_default_shell() {
    local current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" == "zsh" ]]; then
        log_info "恢复默认 shell..."
        
        # 尝试设置为 bash
        if command -v bash &>/dev/null; then
            chsh -s "$(which bash)"
            log_success "已设置 bash 为默认 shell"
        else
            log_warning "bash 不可用，请手动设置默认 shell"
        fi
    else
        log_info "当前 shell 不是 zsh，无需更改"
    fi
}

# 清理缓存和临时文件
cleanup_cache() {
    log_info "清理缓存文件..."
    
    local cache_dirs=(
        "$HOME/.cache/p10k-*"
        "$HOME/.cache/zsh"
    )
    
    for pattern in "${cache_dirs[@]}"; do
        for dir in $pattern; do
            if [[ -d "$dir" ]]; then
                rm -rf "$dir"
                log_success "已删除缓存: $(basename "$dir")"
            fi
        done
    done
    
    # 清理 zsh 历史文件 (可选)
    read -p "是否删除 zsh 历史记录? (y/n) [n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$HOME/.zsh_history"
        log_success "已删除 zsh 历史记录"
    fi
}

# 完全卸载
full_uninstall() {
    log_warning "即将执行完全卸载，这将删除所有 Oh My Zsh 相关文件"
    read -p "确定继续? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "取消卸载"
        return 0
    fi
    
    create_backup
    remove_oh_my_zsh
    remove_config_files
    cleanup_cache
    restore_default_shell
    
    log_success "完全卸载完成"
}

# 部分卸载
partial_uninstall() {
    log_info "执行部分卸载 (仅删除 Oh My Zsh)"
    
    create_backup
    remove_oh_my_zsh
    
    log_success "部分卸载完成，配置文件已保留"
}

# 显示卸载摘要
show_uninstall_summary() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}卸载摘要${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    [[ ! -d "$HOME/.oh-my-zsh" ]] && echo -e "${GREEN}✓ Oh My Zsh 已删除${NC}" || echo -e "${YELLOW}! Oh My Zsh 仍然存在${NC}"
    [[ ! -f "$HOME/.zshrc" ]] && echo -e "${GREEN}✓ .zshrc 已删除${NC}" || echo -e "${YELLOW}! .zshrc 仍然存在${NC}"
    [[ ! -f "$HOME/.p10k.zsh" ]] && echo -e "${GREEN}✓ .p10k.zsh 已删除${NC}" || echo -e "${YELLOW}! .p10k.zsh 仍然存在${NC}"
    
    local current_shell=$(basename "$SHELL")
    echo -e "${BLUE}当前默认 shell: $current_shell${NC}"
    
    if [[ -f "$HOME/.zsh_uninstall_backup_location" ]]; then
        local backup_dir=$(cat "$HOME/.zsh_uninstall_backup_location")
        echo -e "${GREEN}备份位置: $backup_dir${NC}"
    fi
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}卸载完成！${NC}"
    
    if [[ "$current_shell" == "bash" ]]; then
        echo -e "${GREEN}请重新登录以应用 shell 更改${NC}"
    fi
    
    echo -e "${GREEN}========================================${NC}"
}

# 主函数
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    Zsh 配置卸载工具${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    check_zsh_status
    echo
    
    show_uninstall_options
    
    read -p "请选择 (1-5): " choice
    
    case $choice in
        1)
            full_uninstall
            show_uninstall_summary
            ;;
        2)
            partial_uninstall
            show_uninstall_summary
            ;;
        3)
            restore_default_shell
            log_success "默认 shell 恢复完成"
            ;;
        4)
            create_backup
            ;;
        5)
            log_info "取消卸载"
            exit 0
            ;;
        *)
            error_exit "无效选择"
            ;;
    esac
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi