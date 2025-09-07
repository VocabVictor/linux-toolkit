# Linux Toolkit 🛠️

A collection of personal Linux utility scripts and configurations for efficient daily operations and development.

## 📂 Project Structure

```
linux-toolkit/
├── zsh-config/        # Zsh terminal configuration and beautification
├── system/            # System management scripts
├── network/           # Network tools and configurations
├── docker/            # Docker related scripts
├── backup/            # Backup and recovery scripts
├── monitoring/        # System monitoring scripts
├── security/          # Security related tools
└── development/       # Development environment setup
```

## 🚀 Quick Start

### Clone Repository
```bash
git clone https://github.com/yourusername/linux-toolkit.git
cd linux-toolkit
```

### Using Scripts
Each directory contains independent scripts and documentation that can be used separately as needed.

## 📦 Feature Modules

### 1. Zsh Configuration (zsh-config)
Powerful Zsh terminal configuration with Oh-My-Zsh, Powerlevel10k theme and various plugins.

```bash
cd zsh-config
./setup_zsh_enhanced.sh
```

**Features:**
- 🎨 Beautiful Powerlevel10k theme
- 🚀 Smart auto-completion and syntax highlighting
- 📦 Rich plugin ecosystem
- [Detailed Documentation](./zsh-config/README.en.md)

### 2. System Management (system)
Common system management and optimization scripts.

**Included Scripts:**
- `clean_system.sh` - System cleanup script
- `update_system.sh` - System update script
- `system_info.sh` - System information collector
- `optimize_performance.sh` - Performance optimization

### 3. Network Tools (network)
Network configuration and diagnostic tools.

**Included Scripts:**
- `network_speed_test.sh` - Network speed test
- `port_scanner.sh` - Port scanning tool
- `proxy_setup.sh` - Proxy configuration
- `dns_tools.sh` - DNS toolkit

### 4. Docker Tools (docker)
Docker container management and optimization scripts.

**Included Scripts:**
- `docker_cleanup.sh` - Clean unused images and containers
- `docker_stats.sh` - Container resource monitoring
- `docker_backup.sh` - Container backup script
- `compose_manager.sh` - Docker Compose management

### 5. Backup Tools (backup)
Automated backup and recovery scripts.

**Included Scripts:**
- `backup_home.sh` - Home directory backup
- `mysql_backup.sh` - MySQL database backup
- `incremental_backup.sh` - Incremental backup
- `restore_backup.sh` - Restore tool

### 6. Monitoring Tools (monitoring)
System monitoring and alerting scripts.

**Included Scripts:**
- `resource_monitor.sh` - Resource monitoring
- `log_analyzer.sh` - Log analysis
- `process_monitor.sh` - Process monitoring
- `disk_usage_alert.sh` - Disk usage alerts

### 7. Security Tools (security)
System security hardening and audit scripts.

**Included Scripts:**
- `security_audit.sh` - Security audit
- `firewall_setup.sh` - Firewall configuration
- `ssh_hardening.sh` - SSH security hardening
- `password_generator.sh` - Password generator

### 8. Development Environment (development)
Development environment setup and tools.

**Included Scripts:**
- `dev_env_setup.sh` - One-click dev environment setup
- `git_config.sh` - Git configuration script
- `nodejs_setup.sh` - Node.js environment setup
- `python_env.sh` - Python virtual environment management

## 🔧 Common Features

### Environment Detection
All scripts include:
- 🔍 System compatibility check
- 📋 Dependency verification
- 💾 Automatic backup
- 🔄 Error recovery

### Supported Systems
- Ubuntu/Debian
- CentOS/RHEL
- Arch Linux
- macOS (partial support)

## 📝 Usage Examples

### System Initialization
```bash
# 1. Configure Zsh terminal
cd zsh-config && ./setup_zsh_enhanced.sh

# 2. System optimization
cd ../system && ./optimize_performance.sh

# 3. Setup development environment
cd ../development && ./dev_env_setup.sh
```

### Daily Maintenance
```bash
# System cleanup
./system/clean_system.sh

# Docker cleanup
./docker/docker_cleanup.sh

# Backup important data
./backup/backup_home.sh
```

## 🤝 Contributing

Contributions of new scripts or improvements to existing ones are welcome!

### Contribution Steps
1. Fork this repository
2. Create feature branch (`git checkout -b feature/YourScript`)
3. Commit changes (`git commit -m 'Add YourScript'`)
4. Push to branch (`git push origin feature/YourScript`)
5. Create Pull Request

### Script Standards
- Use Bash 4.0+ features
- Include error handling
- Add detailed comments
- Provide usage documentation
- Follow ShellCheck standards

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

Thanks to all open source projects and community contributors!

## 📮 Contact

- Issues: [GitHub Issues](https://github.com/yourusername/linux-toolkit/issues)
- Email: your-email@example.com

---

⭐ If this project helps you, please give it a Star!

## 🔄 Changelog

### v2.0.0 (2024-01)
- Restructured project architecture
- Added multiple feature modules
- Improved Zsh configuration script
- Added uninstall functionality

### v1.0.0 (2023-12)
- Initial version
- Basic Zsh configuration