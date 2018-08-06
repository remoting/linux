root=$(id -u)
if [ "$root" -ne 0 ] ;then
    echo must run as root
    exit 1
fi
MASTER_ADDR="etcd.service.ob.local"
kube::download_cfssl()
{
    set +e
    which cfssl > /dev/null 2>&1
    i=$?
    if [ $i -ne 0 ]; then
        curl -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
        curl -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
        chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
    fi
}
kube::getip() 
{
    host_ips=(`ip addr show |grep inet |grep -v inet6 |grep brd |awk '{print $2}' |cut -f1 -d '/'`)
    if [ "${host_ips[0]}" == "" ]; then
        echo "[ERROR] get ip address error!"
        exit 1
    else
        echo "${host_ips[0]}"
    fi
}
kube::create_cafile() 
{
	if [ ! -f "/etc/etcd/pki/ca.pem" ]; then
  EXPIRY_YEAR=10
  EXPIRY_HOUR="$((EXPIRY_YEAR*8760))h"
  MASTER_IP=$(kube::getip)
  echo "生成ca.pem: $MASTER_ADDR, expiry year: $EXPIRY_YEAR"
  mkdir -p /etc/etcd/pki
 
  cat <<EOF > /etc/etcd/pki/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "$EXPIRY_HOUR"
    },
    "profiles": {
      "etcd": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
         ],
         "expiry": "$EXPIRY_HOUR"
      }
    }
  }
}
EOF

  cat <<EOF > /etc/etcd/pki/ca-csr.json 
{
  "CN": "rootca",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [{
    "C": "CN",
    "ST": "ShenZhen",
    "L": "ShenZhen",
    "O": "PAAS",
    "OU": "System"
  }]
}
EOF


  cat <<EOF > /etc/etcd/pki/etcd-server-csr.json
{
    "CN": "etcd",
    "hosts": [
      "127.0.0.1",
      "10.96.0.1",
      "$MASTER_IP",
      "$MASTER_ADDR",
      "etcd",
      "etcd.default",
      "etcd.default.svc",
      "etcd.default.svc.cluster",
      "etcd.default.svc.cluster.local"
    ], 
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [ 
      {
        "C": "CN",
        "ST": "ShenZhen",
        "L": "ShenZhen",
        "O": "PAAS",
        "OU": "System"
      } 
    ]
}
EOF
  cat <<EOF > /etc/etcd/pki/etcd-client-csr.json
{
    "CN": "client",
    "hosts": [
      "127.0.0.1",
      "10.96.0.1",
      "$MASTER_IP",
      "$MASTER_ADDR",
      "etcd",
      "etcd.default",
      "etcd.default.svc",
      "etcd.default.svc.cluster",
      "etcd.default.svc.cluster.local"
    ], 
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [ 
      {
        "C": "CN",
        "ST": "ShenZhen",
        "L": "ShenZhen",
        "O": "PAAS",
        "OU": "System"
      } 
    ]
}
EOF
  cat <<EOF > /etc/etcd/pki/etcd-peer-csr.json
{
    "CN": "peer",
    "hosts": [
      "127.0.0.1",
      "10.96.0.1",
      "$MASTER_IP",
      "$MASTER_ADDR",
      "etcd",
      "etcd.default",
      "etcd.default.svc",
      "etcd.default.svc.cluster",
      "etcd.default.svc.cluster.local"
    ], 
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [ 
      {
        "C": "CN",
        "ST": "ShenZhen",
        "L": "ShenZhen",
        "O": "PAAS",
        "OU": "System"
      } 
    ]
}
EOF
  cd /etc/etcd/pki
  rm -rf *.pem *.crt *.csr
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
  mv ca.pem ca.crt
  cfssl gencert -ca=ca.crt -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-server-csr.json | cfssljson -bare etcd-server
  mv etcd-server.pem etcd-server.crt
  cfssl gencert -ca=ca.crt -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-client-csr.json | cfssljson -bare etcd-client
  mv etcd-client.pem etcd-client.crt
  cfssl gencert -ca=ca.crt -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-peer-csr.json | cfssljson -bare etcd-peer
  mv etcd-peer.pem etcd-peer.crt
	fi
}


main()
{
    case $1 in
    "d" | "download" )
        kube::download_cfssl
        ;;
    "c" | "create" )
        kube::create_cafile
        ;;
    "a" | "all" )
        kube::download_cfssl
        kube::create_cafile
        ;;
    *)
        echo "usage: $0 a        to all action"
        echo "       $0 d        to download "
        echo "       $0 c        to create "
        ;;
    esac
}

main $@