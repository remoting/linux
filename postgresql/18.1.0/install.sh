# 解压安装
mkdir -p /opt/postgresql
tar -zxvf postgresql-18.1.0-x86_64-unknown-linux-gnu.tar.gz -C /opt/postgresql --strip-components=1

# 创建数据目录（如果还没创建）
mkdir -p /opt/postgresql/data

# 授权（假设二进制文件解压在 /opt/postgresql）
chown -R postgres:postgres /opt/postgresql

# 切换到 postgres 用户执行 initdb
# sudo -u postgres /opt/postgresql/bin/initdb -D /opt/postgresql/data
su -s /bin/bash -c "/opt/postgresql/bin/initdb -D /opt/postgresql/data" postgres
# 启动测试
# sudo -u postgres /opt/postgresql/bin/pg_ctl -D /opt/postgresql/data -l logfile start

cat > /usr/lib/systemd/system/postgresql.service <<EOF
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
Type=forking
User=postgres
Group=postgres

# 环境变量：确保程序能找到自己的 lib 库
Environment=LD_LIBRARY_PATH=/opt/postgresql/lib
# 这里的路径必须指向你的解压目录
WorkingDirectory=/opt/postgresql

# 启动命令：使用 pg_ctl start
ExecStart=/opt/postgresql/bin/pg_ctl start -D /opt/postgresql/data -l /opt/postgresql/data/server.log
# 停止命令
ExecStop=/opt/postgresql/bin/pg_ctl stop -D /opt/postgresql/data -m fast
# 重新加载命令
ExecReload=/opt/postgresql/bin/pg_ctl reload -D /opt/postgresql/data

# 自动重启设置
Restart=on-failure
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

# 执行替换：将包含 listen_addresses 的行替换为 listen_addresses = '*'
# s/ 代表替换，^#? 代表匹配开头可能存在的 # 号
sed -i "s/^#\?listen_addresses = .*/listen_addresses = '*'/" /opt/postgresql/data/postgresql.conf

cat >> /opt/postgresql/data/pg_hba.conf <<EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             0.0.0.0/0                scram-sha-256
EOF

cat > /opt/postgresql/init.sql <<EOF
ALTER USER postgres WITH PASSWORD 'lazy!123EWQ';
EOF

# 启动数据库
systemctl daemon-reload
systemctl start postgresql

/opt/postgresql/bin/psql -U postgres -d postgres -f /opt/postgresql/init.sql