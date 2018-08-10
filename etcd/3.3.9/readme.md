# 无任何证书
etcd --name=etcd-node-001 \
--data-dir=/var/lib/etcd \
--listen-client-urls="http://172.16.211.134:2379" \
--advertise-client-urls="http://172.16.211.134:2379"

etcdctl --endpoints=http://172.16.211.134:2379 member list
---
# 无Client证书，有TSL证书
etcd --name=etcd-node-001 \
--data-dir=/var/lib/etcd \
--key-file="/etc/etcd/pki/etcd-server-key.pem" \
--cert-file="/etc/etcd/pki/etcd-server.crt" \
--listen-client-urls="https://127.0.0.1:2379" \
--advertise-client-urls="https://127.0.0.1:2379"
 
etcdctl --endpoints=https://127.0.0.1:2379 \
    --ca-file=/etc/etcd/pki/ca.crt \
    member list
---
# 有TSL证书 有Client证书
etcd --name=etcd-node-001 \
--data-dir=/var/lib/etcd \
--key-file="/etc/etcd/pki/etcd-server-key.pem" \
--cert-file="/etc/etcd/pki/etcd-server.crt" \
--listen-client-urls="https://127.0.0.1:2379" \
--advertise-client-urls="https://127.0.0.1:2379" \
--client-cert-auth=true \
--trusted-ca-file=/etc/etcd/pki/ca.crt

etcdctl --endpoints=https://127.0.0.1:2379 \
    --ca-file=/etc/etcd/pki/ca.crt \
    --cert-file=/etc/etcd/pki/etcd-client.crt \
    --key-file=/etc/etcd/pki/etcd-client-key.pem \
    member list
---
# 有TSL证书 有Client证书并且有Peer证书 集群模式 查看install.sh


---
# 客户端
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=http://172.16.211.134:2379
etcdctl endpoint status --write-out=table 
etcdctl endpoint health

 