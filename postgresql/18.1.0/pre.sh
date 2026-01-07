# 添加用户
useradd -r -s /sbin/nologin postgres

# 下载MySQL二进制包（替换为对应版本/系统架构）
wget https://github.com/theseus-rs/postgresql-binaries/releases/download/18.1.0/postgresql-18.1.0-x86_64-unknown-linux-gnu.tar.gz