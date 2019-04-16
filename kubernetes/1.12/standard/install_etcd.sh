#!/bin/bash

export ETCD_VERSION=v3.2.24
wget https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz 
tar -xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
mv ./etcd-v3.2.24-linux-amd64/etcd /usr/local/bin/
mv ./etcd-v3.2.24-linux-amd64/etcdctl /usr/local/bin/
rm -rf etcd-$ETCD_VERSION-linux-amd64*


# node1
touch /etc/etcd.env
echo "PEER_NAME=k8s-master-01" >> /etc/etcd.env
echo "PRIVATE_IP=10.11.46.201" >> /etc/etcd.env

cat >/etc/systemd/system/etcd.service <<EOL
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service

[Service]
EnvironmentFile=/etc/etcd.env
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/bin/etcd --name \${PEER_NAME} \\
    --data-dir /var/lib/etcd \\
    --listen-client-urls http://\${PRIVATE_IP}:2379,http://127.0.0.1:2379 \\
    --advertise-client-urls http://\${PRIVATE_IP}:2379

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl start etcd
etcdctl cluster-health 