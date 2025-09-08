# 一键安装命令

## 国际版 (GitHub 直连)
```bash
# Zsh 完整配置
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash

# Docker 清理
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# 系统清理  
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash

# 网络测速
curl -fsSL https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/network/speed.sh | bash

# 克隆仓库
git clone https://github.com/VocabVictor/linux-toolkit.git
```

## 国内加速版 (推荐中国用户)
```bash
# Zsh 完整配置
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/zshconfig/setup.sh | bash

# Docker 清理
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/docker/cleanup.sh | bash

# 系统清理
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/system/clean.sh | bash

# 网络测速
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/VocabVictor/linux-toolkit/master/network/speed.sh | bash

# 克隆仓库
git clone https://gh-proxy.com/https://github.com/VocabVictor/linux-toolkit.git
```

## 环境变量
```bash
# 静默模式
BATCH=true curl -fsSL <url> | bash

# 禁用自动代理
GITHUB_PROXY=false curl -fsSL <url> | bash
```