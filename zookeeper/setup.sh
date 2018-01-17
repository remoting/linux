wget -O /opt/zookeeper-3.4.8.tar.gz https://archive.apache.org/dist/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz 
cd /opt && tar -zxvf zookeeper-3.4.8.tar.gz

cat <<EOF > /lib/systemd/system/zookeeper.service
[Unit]
Description=Zookeeper
Documentation=http://zookeeper.apache.org
After=network.target

[Service]
Type=forking
ExecStart=/opt/zookeeper-3.4.8/bin/zkServer.sh start
ExecStop=/opt/zookeeper-3.4.8/bin/zkServer.sh stop
ExecReload=/opt/zookeeper-3.4.8/bin/zkServer.sh reload

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start zookeeper
systemctl status zookeeper