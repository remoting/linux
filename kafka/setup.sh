wget -O /opt/kafka_2.11-1.0.0.tgz http://mirrors.tuna.tsinghua.edu.cn/apache/kafka/1.0.0/kafka_2.11-1.0.0.tgz
cd /opt && tar -zxvf kafka_2.11-1.0.0.tgz

cat <<EOF > /lib/systemd/system/kafka-zookeeper.service
[Unit]
Description=Kafka Zookeeper
Documentation=http://kafka.apache.org
After=network.target

[Service]
Type=simple
ExecStart=/opt/kafka_2.11-1.0.0/bin/zookeeper-server-start.sh /opt/kafka_2.11-1.0.0/config/zookeeper.properties
ExecStop=/opt/kafka_2.11-1.0.0/bin/zookeeper-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka server
Documentation=http://kafka.apache.org
After=network.target kafka-zookeeper.service

[Service]
Type=simple
ExecStart=/opt/kafka_2.11-1.0.0/bin/kafka-server-start.sh /opt/kafka_2.11-1.0.0/config/server.properties
ExecStop=/opt/kafka_2.11-1.0.0/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start kafka-zookeeper
systemctl start kafka
systemctl status zookeeper
systemctl status kafka