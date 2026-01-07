# 1. 安装依赖
apt install -y libaio1t64 libnuma1 libncurses6

ln -s /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1

# 2. 创建mysql用户（避免root运行）
useradd -r -s /sbin/nologin mysql

# 3. 下载MySQL二进制包（替换为对应版本/系统架构）
wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.7-linux-glibc2.28-x86_64-minimal.tar.xz
