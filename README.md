# Linux Toolkit 🛠️

个人 Linux 实用脚本和配置集合，让日常运维和开发更高效。

## 📂 项目结构

```
linux-toolkit/
├── zsh-config/        # Zsh 终端配置和美化
├── system/            # 系统管理脚本
├── network/           # 网络工具和配置
├── docker/            # Docker 相关脚本
├── backup/            # 备份和恢复脚本
├── monitoring/        # 系统监控脚本
├── security/          # 安全相关工具
└── development/       # 开发环境配置
```

## 🚀 快速开始

### 克隆仓库
```bash
git clone https://github.com/yourusername/linux-toolkit.git
cd linux-toolkit
```

### 使用脚本
每个目录都包含独立的脚本和文档，可以根据需要单独使用。

## 📦 功能模块

### 1. Zsh 配置 (zsh-config)
强大的 Zsh 终端配置，包含 Oh-My-Zsh、Powerlevel10k 主题和各种插件。

```bash
cd zsh-config
./setup_zsh_enhanced.sh
```

**特性：**
- 🎨 美观的 Powerlevel10k 主题
- 🚀 智能自动补全和语法高亮
- 📦 丰富的插件生态
- [详细文档](./zsh-config/README.md)

### 2. 系统管理 (system)
常用的系统管理和优化脚本。

**包含脚本：**
- `clean_system.sh` - 系统清理脚本
- `update_system.sh` - 系统更新脚本
- `system_info.sh` - 系统信息收集
- `optimize_performance.sh` - 性能优化

### 3. 网络工具 (network)
网络配置和诊断工具。

**包含脚本：**
- `network_speed_test.sh` - 网速测试
- `port_scanner.sh` - 端口扫描工具
- `proxy_setup.sh` - 代理配置
- `dns_tools.sh` - DNS 工具集

### 4. Docker 工具 (docker)
Docker 容器管理和优化脚本。

**包含脚本：**
- `docker_cleanup.sh` - 清理无用镜像和容器
- `docker_stats.sh` - 容器资源监控
- `docker_backup.sh` - 容器备份脚本
- `compose_manager.sh` - Docker Compose 管理

### 5. 备份工具 (backup)
自动化备份和恢复脚本。

**包含脚本：**
- `backup_home.sh` - 家目录备份
- `mysql_backup.sh` - MySQL 数据库备份
- `incremental_backup.sh` - 增量备份
- `restore_backup.sh` - 恢复工具

### 6. 监控工具 (monitoring)
系统监控和报警脚本。

**包含脚本：**
- `resource_monitor.sh` - 资源监控
- `log_analyzer.sh` - 日志分析
- `process_monitor.sh` - 进程监控
- `disk_usage_alert.sh` - 磁盘使用告警

### 7. 安全工具 (security)
系统安全加固和检查脚本。

**包含脚本：**
- `security_audit.sh` - 安全审计
- `firewall_setup.sh` - 防火墙配置
- `ssh_hardening.sh` - SSH 安全加固
- `password_generator.sh` - 密码生成器

### 8. 开发环境 (development)
开发环境配置和工具。

**包含脚本：**
- `dev_env_setup.sh` - 开发环境一键配置
- `git_config.sh` - Git 配置脚本
- `nodejs_setup.sh` - Node.js 环境配置
- `python_env.sh` - Python 虚拟环境管理

## 🔧 通用功能

### 环境检测
所有脚本都包含：
- 🔍 系统兼容性检查
- 📋 依赖验证
- 💾 自动备份
- 🔄 错误恢复

### 支持系统
- Ubuntu/Debian
- CentOS/RHEL
- Arch Linux
- macOS (部分支持)

## 📝 使用示例

### 系统初始化
```bash
# 1. 配置 Zsh 终端
cd zsh-config && ./setup_zsh_enhanced.sh

# 2. 系统优化
cd ../system && ./optimize_performance.sh

# 3. 配置开发环境
cd ../development && ./dev_env_setup.sh
```

### 日常维护
```bash
# 系统清理
./system/clean_system.sh

# Docker 清理
./docker/docker_cleanup.sh

# 备份重要数据
./backup/backup_home.sh
```

## 🤝 贡献指南

欢迎贡献新的脚本或改进现有脚本！

### 贡献步骤
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/YourScript`)
3. 提交更改 (`git commit -m 'Add YourScript'`)
4. 推送到分支 (`git push origin feature/YourScript`)
5. 创建 Pull Request

### 脚本规范
- 使用 Bash 4.0+ 特性
- 包含错误处理
- 添加详细注释
- 提供使用文档
- 遵循 ShellCheck 规范

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

感谢所有开源项目和社区贡献者！

## 📮 联系方式

- Issues: [GitHub Issues](https://github.com/yourusername/linux-toolkit/issues)
- Email: your-email@example.com

---

⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！

## 🔄 更新日志

### v2.0.0 (2024-01)
- 重构项目结构
- 添加多个功能模块
- 改进 Zsh 配置脚本
- 添加卸载功能

### v1.0.0 (2023-12)
- 初始版本
- 基础 Zsh 配置