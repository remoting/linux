#!/bin/bash

export ETCD_VERSION=v3.2.24
wget https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz 
tar -xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
mv ./etcd-v3.2.24-linux-amd64/etcd /usr/local/bin/
mv ./etcd-v3.2.24-linux-amd64/etcdctl /usr/local/bin/
rm -rf etcd-$ETCD_VERSION-linux-amd64*
 
systemctl daemon-reload
systemctl start etcd
etcdctl cluster-health