root=$(id -u)
if [ "$root" -ne 0 ] ;then
    echo must run as root
    exit 1
fi
kube::getip() {
    host_ips=(`ip addr show |grep inet |grep -v inet6 |grep brd |awk '{print $2}' |cut -f1 -d '/'`)
    if [ "${host_ips[0]}" == "" ]; then
        echo "[ERROR] get ip address error!"
        exit 1
    else
        echo "${host_ips[0]}"
    fi
}
kube::download_etcd()
{    
	if [ ! -f "./etcd-v3.3.9-linux-amd64.tar.gz" ]; then
		curl -oL etcd-v3.3.9-linux-amd64.tar.gz https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz
	fi
	set +e
    which etcd > /dev/null 2>&1
    i=$?
    if [ $i -ne 0 ]; then
		tar -zxvf etcd-v3.3.9-linux-amd64.tar.gz
		mv ./etcd-v3.3.9-linux-amd64/etcd /usr/local/bin/
		mv ./etcd-v3.3.9-linux-amd64/etcdctl /usr/local/bin/
	fi
	echo etcd has been download
} 
kube::config_etcd()
{
	local MASTER_IP=$(kube::getip)
	cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd
After=network.service
Wants=network.service

[Service]
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/conf.yaml
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
	cat <<EOF > /etc/etcd/conf.yaml
name: "etcd-node-001"
data-dir: "/var/lib/etcd"
listen-client-urls: https://$MASTER_IP:2379
advertise-client-urls: https://$MASTER_IP:2379
# cluster begin
listen-peer-urls: https://$MASTER_IP:2380
initial-advertise-peer-urls: https://$MASTER_IP:2380
initial-cluster: etcd-node-001=https://192.168.108.128:2380,etcd-node-002=https://192.168.108.129:2380,etcd-node-003=https://192.168.108.130:2380
initial-cluster-token: "etcd-cluster"
initial-cluster-state: "new"
peer-transport-security:
  cert-file: /etc/etcd/pki/etcd-peer.crt
  key-file: /etc/etcd/pki/etcd-peer-key.pem
  peer-client-cert-auth: true
  trusted-ca-file: /etc/etcd/pki/ca.crt
# cluster end
key-file: /etc/etcd/pki/etcd-server-key.pem
cert-file: /etc/etcd/pki/etcd-server.crt
client-transport-security:
  cert-file: /etc/etcd/pki/etcd-client.crt
  key-file: /etc/etcd/pki/etcd-client-key.pem
  client-cert-auth: true
  trusted-ca-file: /etc/etcd/pki/ca.crt
debug: false
EOF
	systemctl daemon-reload && systemctl enable etcd && systemctl start etcd
}
kube::install_etcd()
{
	`dirname $0`/certs.sh a
	kube::download_etcd
	kube::config_etcd
}


main()
{
    case $1 in
    "e" | "etcd" )
        kube::install_etcd
        ;;
    *)
        echo "usage: $0 etcd"
        echo "       $0 etcd        to setup etcd "
        ;;
    esac
}

main $@