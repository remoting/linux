#!/bin/bash
 
root=$(id -u)
if [ "$root" -ne 0 ] ;then
    echo must run as root
    exit 1
fi

MASTER_ADDR="k8s.service.ob.local"
kube::getip() {
    host_ips=(`ip addr show |grep inet |grep -v inet6 |grep brd |awk '{print $2}' |cut -f1 -d '/'`)
    if [ "${host_ips[0]}" == "" ]; then
        echo "[ERROR] get ip address error!"
        exit 1
    else
        echo "${host_ips[0]}"
    fi
}
kube::master_config_cafile() {
  if [ ! -f "/etc/kubernetes/ssl/ca.pem" ]; then

  EXPIRY_YEAR=10
  EXPIRY_HOUR="$((EXPIRY_YEAR*8760))h"
  MASTER_IP=$(kube::getip)
  echo "生成k8s密钥 master: $MASTER_ADDR, expiry year: $EXPIRY_YEAR"
  mkdir -p /etc/kubernetes/ssl
 
  cat <<EOF > /etc/kubernetes/ssl/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "$EXPIRY_HOUR"
    },
    "profiles": {
      "kubernetes": {
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

  cat <<EOF > /etc/kubernetes/ssl/ca-csr.json 
{
  "CN": "kubernetes",
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

  cat <<EOF > /etc/kubernetes/ssl/kubernetes-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "10.96.0.1",
      "$MASTER_IP",
      "$MASTER_ADDR",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ], "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [ {
      "C": "CN",
      "ST": "ShenZhen",
      "L": "ShenZhen",
      "O": "PAAS",
      "OU": "System"
    } ]
}
EOF

  # config ssl
  #rm -rf *.pem *.csr
  cd /etc/kubernetes/ssl
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

  fi
}
kube::master_config_auth()
{
    mkdir -p /etc/kubernetes/auth
    BOOTSTRAP_TOKEN="$(echo $MASTER_ADDR|md5sum|cut -f 1 -d ' ')"
    echo "$BOOTSTRAP_TOKEN,kubelet-bootstrap,10001,\"system:kubelet-bootstrap\"" > /etc/kubernetes/auth/token.csv
    echo "123456,admin,admin" > /etc/kubernetes/auth/user.csv
}
kube::master_config_yaml()
{
    docker pull registry.cn-hangzhou.aliyuncs.com/remoting/kube-apiserver:v1.6.11
    docker pull registry.cn-hangzhou.aliyuncs.com/remoting/kube-scheduler:v1.6.11
    docker pull registry.cn-hangzhou.aliyuncs.com/remoting/kube-controller-manager:v1.6.11
    mkdir -p /etc/kubernetes/manifests
    local master=$(kube::getip)
    echo "Install master to ip: $master"
    cat <<EOF > /etc/kubernetes/manifests/master.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-master
  namespace: kube-system
  labels:
    component: kube-apiserver
spec:
  hostNetwork: true
  containers:
  - name: kube-apiserver
    image: registry.cn-hangzhou.aliyuncs.com/remoting/kube-apiserver:v1.6.11
    command:
    - kube-apiserver
    # - --v=4
    - --insecure-port=8080
    - --insecure-bind-address=127.0.0.1
    - --secure-port=6443
    - --advertise-address=$master
    - --bind-address=$master
    - --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem
    - --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem
    - --client-ca-file=/etc/kubernetes/ssl/ca.pem
    - --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --authorization-mode=AlwaysAllow
    - --anonymous-auth=false
    - --basic-auth-file=/etc/kubernetes/auth/user.csv
    - --kubelet-https=true
    - --experimental-bootstrap-token-auth
    - --token-auth-file=/etc/kubernetes/auth/token.csv
    - --service-node-port-range=20000-40000
    - --admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota
    - --storage-backend=etcd3
    - --etcd-servers=http://$master:2379
    - --allow-privileged=true
    - --service-cluster-ip-range=10.96.0.0/16
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 8080
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /etc/kubernetes/
      name: k8s
      readOnly: true
  - name: kube-scheduler
    image: registry.cn-hangzhou.aliyuncs.com/remoting/kube-scheduler:v1.6.11
    command:
    - kube-scheduler
    - --leader-elect=true
    - --master=http://127.0.0.1:8080
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10251
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 100m
  - name: kube-controller-manager
    image: registry.cn-hangzhou.aliyuncs.com/remoting/kube-controller-manager:v1.6.11
    command:
    - kube-controller-manager
    - --leader-elect=true
    - --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem
    - --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --root-ca-file=/etc/kubernetes/ssl/ca.pem
    - --master=http://127.0.0.1:8080
    #- --allocate-node-cidrs=true
    #- --cluster-cidr=10.50.0.0/16
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10252
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 200m
    volumeMounts:
    - mountPath: /etc/kubernetes/
      name: k8s
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/kubernetes
    name: k8s
EOF
}

kube::show_config_token()
{
    local K8STOKEN=$(cat /etc/kubernetes/auth/token.csv | awk -F, '{print $1}')
    echo "Install master token: $K8STOKEN"
}
kube::install_etcd()
{
    set +e
    which etcd > /dev/null 2>&1
    i=$?
    if [ $i -ne 0 ]; then
        yum install -y etcd
        sed -i 's/localhost/0.0.0.0/' /etc/etcd/etcd.conf
        systemctl enable etcd && systemctl start etcd
    fi
    echo etcd has been installed
}

kube::install_docker()
{
    set +e
    which docker > /dev/null 2>&1
    i=$?
    if [ $i -ne 0 ]; then
        yum install -y --nogpgcheck \
            http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/Packages/docker-engine-selinux-1.13.1-1.el7.centos.noarch.rpm \
            http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/Packages/docker-engine-1.13.1-1.el7.centos.x86_64.rpm

        systemctl enable docker && systemctl start docker
    fi
    echo docker has been installed
}

kube::install_kubelet()
{   
    mkdir -p /etc/kubernetes
    set +e
    which kubelet > /dev/null 2>&1
    i=$?
    if [ $i -ne 0 ]; then

yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/b542021d5f32457f8c1f6f726aaa077eec66b0906440a020cfada28275df50f7-kubectl-1.6.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/b58a3f13d494458fbe23dbf22abc0213dc2c9ffb1e30f76dad3d7321d0715444-kubelet-1.6.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/e7a4403227dd24036f3b0615663a371c4e07a95be5fee53505e647fd8ae58aa6-kubernetes-cni-0.5.1-0.x86_64.rpm

cat <<EOF >/etc/kubernetes/config.sh
#!/bin/bash

function get_ip() {
    local IPS=\$(ip addr show | grep inet | grep -v inet6 | grep brd | awk '{print \$2}' | cut -f1 -d '/')

    if [ "\${IPS[0]}" == "" ]; then
        echo "[ERROR] get ip address error."
        exit 1
    else
       echo \${IPS[0]}
    fi
}

IP=\$(get_ip)
sed -i "s/\"--hostname-override=.*\"/\"--hostname-override=\$IP\"/g" /etc/kubernetes/kubelet.env;
EOF
cat <<EOF >/etc/kubernetes/kubelet.env
NODE_HOSTNAME="--hostname-override=0.0.0.0"
# KUBELET_ARGS="--cgroup-driver=cgroupfs --cgroups-per-qos=false --enforce-node-allocatable=\"\""
EOF

chmod +x /etc/kubernetes/config.sh 

local base="  --allow-privileged=true \\
  --kubeconfig=/etc/kubernetes/kubelet.conf \\
  --require-kubeconfig=true \\
  --network-plugin=cni \\
  --cni-conf-dir=/etc/cni/net.d \\
  --cni-bin-dir=/opt/cni/bin \\
  --cluster-dns=10.96.0.10 \\
  --cluster-domain=cluster.local \\"
cat <<EOF > /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/
After=docker.service
Wants=docker.service

[Service]
EnvironmentFile=-/etc/kubernetes/kubelet.env
ExecStartPre=-/etc/kubernetes/config.sh
ExecStart=/usr/bin/kubelet \\
$base
  --pod-manifest-path=/etc/kubernetes/manifests \\
  --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.0 \\
  \$NODE_HOSTNAME \\
  \$KUBELET_ARGS
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet
    fi
    echo kubelet has been installed
}
kube::kubelet_config() 
{
  echo "生成kubelet.conf配置"
  KUBE_APISERVER="https://$MASTER_ADDR:6443"
  BOOTSTRAP_TOKEN="$1"
 
  kubectl config set-cluster kubernetes \
      --server=${KUBE_APISERVER} \
      --insecure-skip-tls-verify=true \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config use-context default --kubeconfig=/etc/kubernetes/kubelet.conf
}
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

kube::install_master()
{
    kube::install_docker
    kube::install_kubelet
    kube::download_cfssl
    kube::master_config_cafile
    kube::master_config_auth
    local K8STOKEN=$(kube::show_config_token)
    kube::kubelet_config $K8STOKEN
    kube::master_config_yaml
    kube::show_config_token

    systemctl restart kubelet
}
 
kube::install_node()
{
    kube::install_docker
    kube::install_kubelet
    kube::kubelet_config $@

    systemctl restart kubelet
}

main()
{
    case $1 in
    "e" | "etcd" )
        kube::install_etcd
        ;;
    "m" | "master" )
        kube::install_master
        ;;
    "n" | "node" )
        if [ $# -lt 2 ]; then
            echo "参数错误: install.sh node token"
        else
            kube::install_node $2
        fi
        ;;
    "k" | "kubelet" ) 
        kube::install_kubelet
        ;;
    "d" | "docker" ) 
        kube::install_docker
        ;;
    "t" | "token" ) 
        kube::show_config_token
        ;;
    *)
        echo "usage: $0 m[master] | e[etcd] | n[node] | k[kubelet] | d[docker] | t[token]"
        echo "       $0 master      to setup master "
        echo "       $0 etcd        to setup etcd "
        echo "       $0 node        to setup node "
        echo "       $0 kubelet     to setup kubelet "
        echo "       $0 docker      to setup docker "
        echo "       $0 token       show token "
        echo "       unkown command $0 $@"
        ;;
    esac
}

main $@