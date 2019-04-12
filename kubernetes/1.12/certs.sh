#!/bin/bash
 
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
 
kube::create_cert_apiserver()
{
	local NODE_NAME=$1
	local MASTER_IP=$2
	local MASTER_DNS=$3
	local CORE_DNS=$4
cat <<EOF > apiserver-csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kube-apiserver

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${NODE_NAME}
DNS.2 = kubernetes
DNS.3 = kubernetes.default
DNS.4 = kubernetes.default.svc
DNS.5 = kubernetes.default.svc.cluster
DNS.6 = kubernetes.default.svc.cluster.local
IP.1 = ${MASTER_IP}
IP.2 = ${MASTER_DNS}
IP.3 = ${CORE_DNS}

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

  openssl genrsa -out apiserver.key 2048
  openssl req -new -key apiserver.key -out apiserver.csr -config apiserver-csr.conf
  openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 3650 -extensions v3_ext -extfile apiserver-csr.conf
  rm apiserver.csr -f
  rm apiserver-csr.conf -f
}
kube::create_cert_apiserver_kubelet_client()
{
cat <<EOF > apiserver-kubelet-client-csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
O = system:masters
CN = kube-apiserver-kubelet-client

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
  openssl genrsa -out apiserver-kubelet-client.key 2048
  openssl req -new -key apiserver-kubelet-client.key -out apiserver-kubelet-client.csr -config apiserver-kubelet-client-csr.conf
  openssl x509 -req -in apiserver-kubelet-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver-kubelet-client.crt -days 3650
  rm apiserver-kubelet-client.csr -f
  rm apiserver-kubelet-client-csr.conf -f
}
kube::create_cert_front_proxy_client()
{
cat <<EOF > front-proxy-client-csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = front-proxy-client

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
  openssl genrsa -out front-proxy-client.key 2048
  openssl req -new -key front-proxy-client.key -out front-proxy-client.csr -config front-proxy-client-csr.conf
  openssl x509 -req -in front-proxy-client.csr -CA front-proxy-ca.crt -CAkey front-proxy-ca.key -CAcreateserial -out front-proxy-client.crt -days 3650
  rm front-proxy-client.csr -f
  rm front-proxy-client-csr.conf -f
}
kube::create_sa()
{ 
  openssl genrsa -out sa.key 2048
  openssl rsa -in sa.key -pubout > sa.pub
}
kube::create_kubernetes_ca() 
{ 
  openssl genrsa -out ca.key 2048
  openssl req -x509 -new -nodes -key ca.key -subj "/CN=kubernetes" -days 3650 -out ca.crt
}
kube::create_front_proxy_ca()
{ 
  openssl genrsa -out front-proxy-ca.key 2048
  openssl req -x509 -new -nodes -key front-proxy-ca.key -subj "/CN=front-proxy-ca" -days 3650 -out front-proxy-ca.crt
}
kube::create_ca()
{
	kube::create_kubernetes_ca
	kube::create_front_proxy_ca
}
kube::create_kube()
{
  kube::create_cert_apiserver "node001" "192.168.0.1" "10.244.0.1" "10.244.0.2"
  kube::create_cert_apiserver_kubelet_client
  kube::create_cert_front_proxy_client
  kube::create_sa
  rm ca.srl -f
  rm front-proxy-ca.srl -f
}



main()
{
    case $1 in
    "ca" )
        kube::create_ca
        ;; 
    "kube" )
        kube::create_kube
        ;;
    "all" )
        kube::create_ca
        kube::create_kube
        ;;
    *)
        echo "usage: $0 all        to all action"
        echo "       $0 ca         to create ca"
        echo "       $0 kube       to create kubernetes"
        ;;
    esac
}
#openssl x509  -noout -text -in apiserver.crt 
main $@