cd ~/setup/

# 1. 解压到自定义目录（绿色版核心：指定独立目录）
mkdir -p /opt/mysql
tar -xvf mysql-8.4.7-linux-glibc2.28-x86_64-minimal.tar.xz -C /opt/mysql --strip-components=1

# 2. 创建数据/日志/配置目录
mkdir -p /opt/mysql/{data,logs,tmp,conf}
chown -R mysql:mysql /opt/mysql

cat > /opt/mysql/conf/my.cnf <<EOF
[mysqld]
# 基础配置
basedir = /opt/mysql
datadir = /opt/mysql/data
socket = /opt/mysql/tmp/mysql.sock
pid-file = /opt/mysql/tmp/mysqld.pid
tmpdir = /opt/mysql/tmp

# 网络配置
port = 3306
bind-address = 0.0.0.0

# 字符集
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# 日志配置
log-error = /opt/mysql/logs/mysqld.err
slow_query_log = 1
slow_query_log_file = /opt/mysql/logs/slow.log
long_query_time = 2

# 安全配置
skip-name-resolve

[mysql]
default-character-set = utf8mb4
socket = /opt/mysql/tmp/mysql.sock

[mysqld_safe]
log-error = /opt/mysql/logs/mysqld.err
EOF

cat > /usr/lib/systemd/system/mysql.service <<EOF
[Unit]
Description=MySQL Server (Green Version)
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Service]
User=mysql
Group=mysql
Type=forking
TimeoutSec=0
PermissionsStartOnly=true
PIDFile=/opt/mysql/tmp/mysqld.pid
# 适配绿色版的核心修改：指定正确的二进制路径+配置文件
ExecStart=/opt/mysql/bin/mysqld \
          --defaults-file=/opt/mysql/conf/my.cnf \
          --daemonize \
          --pid-file=/opt/mysql/tmp/mysqld.pid

LimitNOFILE=5000
Restart=on-failure
RestartPreventExitStatus=1
Environment=MYSQLD_PARENT_PID=1
WorkingDirectory=/opt/mysql

[Install]
WantedBy=multi-user.target
EOF

cat > /opt/mysql/init.sql <<EOF
-- 设置本地 root 密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'lazy!123EWQ';

-- 创建远程 root 用户
CREATE USER 'root'@'%' IDENTIFIED BY 'lazy!123EWQ';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 3. 初始化数据库
/opt/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/opt/mysql/data --basedir=/opt/mysql

# 4. 启动数据库
systemctl daemon-reload
systemctl start mysql

# 5. 设置管理员账号
/opt/mysql/bin/mysql -uroot -S /opt/mysql/tmp/mysql.sock < /opt/mysql/init.sql



