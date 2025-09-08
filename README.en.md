# Linux Toolkit

A collection of Linux utility scripts for system management and development environment configuration. All scripts are designed to work without root privileges, using intelligent dependency handling and user-space installations.

## Architecture Design

### Project Structure

```
linux-toolkit/
├── lib/
│   └── common.sh       # Unified function library (no code duplication)
├── zshconfig/          # Zsh configuration module
│   ├── setup.sh        # Automated installation and configuration
│   └── uninstall.sh    # Clean uninstall
├── system/             # System management module
│   ├── clean.sh        # Intelligent system cleanup
│   └── info.sh         # System information viewer
├── network/            # Network tools module
│   └── speed.sh        # Network performance testing
├── docker/             # Docker management module
│   └── cleanup.sh      # Container and image cleanup
└── backup/             # Data backup module
    └── home.sh         # Personal file backup
```

### Dual-Mode Execution Architecture

Each script supports two execution modes:

1. **Local execution**: Uses local `lib/common.sh`
2. **Remote execution**: Automatically downloads `common.sh` to temporary file

This design eliminates code duplication and unifies logging output, error handling, and common utility functions.

## Quick Start

### Installation Method Description

All scripts are designed to **run without root privileges**:

- **Automatic dependency handling**: Scripts detect required tools and provide clear installation guidance
- **User-space installation**: Tools install to `~/.local/bin` (like zsh, speedtest-cli)
- **Graceful degradation**: Automatically switches to user-executable operations when missing system privileges
- **Clear prompts**: Explicitly indicates which operations require manual system package installation

### One-Click Execution Scripts (Recommended)

Scripts support standalone execution with automatic dependency download:

```bash
# Zsh configuration (auto-downloads common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash

# System cleanup (auto-downloads common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash

# Docker cleanup (auto-downloads common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# Network speed test (auto-downloads common.sh)
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/network/speed.sh | bash
```

### Local Installation

```bash
git clone https://github.com/VocabVictor/linux-toolkit.git
cd linux-toolkit
make install  # Install to ~/bin
make test     # Run tests
```

## Feature Modules

### Zsh Environment Configuration (zshconfig)

Automatically installs Oh My Zsh + Powerlevel10k, completely without root privileges. Automatically handles dependencies, provides clear manual installation guidance.

**Features**: Framework installation, theme beautification, syntax highlighting, intelligent completion, configuration backup

```bash
# Local execution
./zshconfig/setup.sh
./zshconfig/uninstall.sh
```

### System Management (system)

**Intelligent cleanup**: `clean.sh` - Safe cleanup without root privileges, handles user caches and temporary files, provides system-level cleanup command suggestions  
**System information**: `info.sh` - Displays system configuration and resource usage

### Docker Management (docker)

**Comprehensive cleanup**: `cleanup.sh` - One-click cleanup of stopped containers, unused images, volumes, networks, and build cache

### Network Tools (network)

**Speed testing**: `speed.sh` - Automatically installs speedtest-cli to user directory when unavailable, tests upload/download bandwidth and latency

### Data Backup (backup)

**Personal backup**: `home.sh` - Intelligent backup of configuration files, SSH keys, and important data

## Configuration Options

Supports environment variables to control script behavior:

```bash
# Silent mode (non-interactive execution)
BATCH=true curl -fsSL <script_url> | bash

# CI environment mode
CI=true curl -fsSL <script_url> | bash

# Custom download timeout (seconds)
DOWNLOAD_TIMEOUT=60 curl -fsSL <script_url> | bash
```

## System Support

| System | Status | Description |
|--------|--------|-------------|
| Ubuntu/Debian | ✅ Full support | No root privileges required, graceful degradation |
| CentOS/RHEL | ✅ Full support | No root privileges required, graceful degradation |
| Arch Linux | ✅ Full support | No root privileges required, graceful degradation |
| macOS | ⚠️ Partial support | System cleanup functionality not supported |

## Development Guide

```bash
make deps     # Install development dependencies (shellcheck)
make test     # Syntax validation for all scripts
make lint     # shellcheck code quality check
make install  # Install to ~/bin directory
```

### Technical Features

- **No root privileges required**: All scripts run under normal user permissions
- **Intelligent dependency handling**: Automatically detects dependencies and provides clear manual installation guidance
- **Graceful degradation**: Automatically switches to user-space operations when missing system permissions
- **Zero dependencies**: Remote execution requires no installation, automatically downloads dependencies
- **Dual-mode**: Local development + remote one-click deployment
- **Error handling**: Unified exception handling and logging output
- **Security**: Automatic temporary file cleanup, `set -euo pipefail`
- **Compatibility**: Supports curl/wget, multi-distribution compatibility

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

Welcome to submit Issues and Pull Requests.

- Bug reports: [GitHub Issues](https://github.com/VocabVictor/linux-toolkit/issues)
- Feature suggestions: Submit through Pull Request