# Claude Development Guide

This document contains important information for Claude when working on this project.

## Project Overview
Linux Toolkit is a collection of utility scripts for Linux system management and development environment configuration.

## Project Structure
```
linux-toolkit/
├── lib/                # Common function library (sourced by other scripts)
├── zshconfig/          # Zsh configuration tools
├── system/             # System management tools
├── network/            # Network tools
├── docker/             # Docker management
└── backup/             # Backup tools
```

## Important Notes

### Directory Naming
- The Zsh configuration directory is `zshconfig/` (NOT `zsh-config/`)
- This was recently renamed from `zsh-config/` to follow consistent naming conventions

### Script Execution Modes
Scripts in this project support two execution modes:
1. **Local execution**: `./script.sh` (sources lib/common.sh)
2. **Remote execution**: `curl -fsSL <url> | bash` (needs inline functions)

### Common Issues and Solutions

#### BASH_SOURCE Error in Curl Pipe
When scripts are executed via `curl | bash`, the `BASH_SOURCE` variable is not available. Scripts that support remote execution must detect this and define required functions inline.

#### Testing Commands
Before committing, always run:
```bash
make test    # Run tests
make lint    # Check shell scripts with shellcheck
```

## Code Standards

### Shell Scripts
- Use `set -euo pipefail` for error handling
- Source common.sh for local execution
- Provide inline functions for remote execution
- Use consistent error/info/warn/ok functions

### Documentation
- No emojis in technical documentation
- Use clear, concise language
- Keep README focused on essential information
- Avoid marketing language

## Recent Changes
- Renamed `zsh-config/` to `zshconfig/` for consistency
- Fixed sourcing patterns to use `BASH_SOURCE` consistently
- Removed duplicate smart_download functions
- Eliminated unsafe curl|bash patterns from documentation

## GitHub Repository
- Repository: VocabVictor/linux-toolkit
- Main branch: master
- All one-click install URLs should reference the correct paths

## Testing Checklist
- [ ] Scripts work locally: `./script.sh`
- [ ] Scripts work remotely: `curl -fsSL <url> | bash`
- [ ] All file paths are correct
- [ ] No hardcoded URLs to incorrect repositories
- [ ] Documentation matches actual code structure