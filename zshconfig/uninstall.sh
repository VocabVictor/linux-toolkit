#!/bin/bash
# Linux Toolkit - Zsh uninstaller
# Copyright (c) 2025 Linux Toolkit. MIT License.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

info "Uninstalling Oh My Zsh configuration"

# Backup current config
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.uninstall.backup.$(date +%Y%m%d_%H%M%S) && info "Backed up .zshrc"

# Remove Oh My Zsh
if [ -d ~/.oh-my-zsh ]; then
    confirm "Remove Oh My Zsh directory?" && rm -rf ~/.oh-my-zsh && ok "Removed Oh My Zsh"
fi

# Restore bash as default shell
if [ "$SHELL" = "$(which zsh)" ]; then
    confirm "Switch back to bash?" && chsh -s /bin/bash && ok "Switched to bash"
fi

# Remove zsh configs
[ -f ~/.p10k.zsh ] && confirm "Remove .p10k.zsh?" && rm ~/.p10k.zsh
[ -f ~/.zshrc ] && confirm "Remove .zshrc?" && rm ~/.zshrc

ok "Uninstallation completed"