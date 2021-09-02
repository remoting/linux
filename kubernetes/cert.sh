#!/bin/bash

cert::create()
{
cat <<EOF > dashboard-csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
CN = server
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = "*"
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

  openssl genrsa -out dashboard.key 2048
  openssl req -new -key dashboard.key -out dashboard.csr -config dashboard-csr.conf
  openssl x509 -req -in dashboard.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out dashboard.crt -days 3650 -extensions v3_ext -extfile dashboard-csr.conf
}

cert::create_ca() 
{ 
  openssl genrsa -out ca.key 2048
  openssl req -x509 -new -nodes -key ca.key -subj "/CN=kubernetes" -days 3650 -out ca.crt
}

main()
{
    case $1 in
    "ca" )
        cert::create_ca
        ;; 
    "cert" )
        cert::create
        ;;
    "all" )
        cert::create_ca
        cert::create
        ;;
    *)
        echo "usage: $0 all        to all action"
        echo "       $0 ca         to create ca"
        echo "       $0 cert       to create kubernetes"
        ;;
    esac
}
 
main $@



# cd ~ && mkdir certs && cd certs
# kubectl delete secret kubernetes-dashboard-certs -n kube-system
# kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs -n kube-system
# kubectl get pods -o wide -n kube-system | grep kubernetes-dashboard | awk '{print $1}'
# kubectl delete pod $(kubectl get pods -o wide -n kube-system | grep kubernetes-dashboard | awk '{print $1}') -n kube-system
# kubectl get pods -o wide -n kube-system

# kubectl create secret docker-registry regcred --docker-server=http://registry.dev.chelizitech.com --docker-username=xxx --docker-password=xxx --docker-email=r@y.cn
# kubectl create secret docker-registry regcred --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=
# kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'





