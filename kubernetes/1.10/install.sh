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

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://4ssmxahm.mirror.aliyuncs.com”]
}
EOF
        systemctl daemon-reload && systemctl enable docker && systemctl start docker

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

# 依赖socat x86_64 1.7.3.2-2.el7| socat-1.7.3.2-2.el7.x86_64
yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/pool/1eed768852fa3e497e1b7bdf4e93afbe3b4b0fdcb59fda801d817736578b9838-kubectl-1.10.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/94d062f2d86b8f4f55f4d23a3610af25931da9168b7f651967c269273955a5a2-kubelet-1.10.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/fe33057ffe95bfae65e2f269e1b05e99308853176e24a4d027bc082b471a07c0-kubernetes-cni-0.6.0-0.x86_64.rpm

cat <<EOF >/etc/kubernetes/kubelet.env
# KUBELET_ARGS="--resolv-conf=/etc/resolv.conf --enforce-node-allocatable=\"\""
EOF
 
local base="--kubeconfig=/etc/kubernetes/kubelet.conf \\
  --fail-swap-on=false \\
  --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/k10/pause-amd64:3.1 \\
  --log-dir=/var/log/kubelet \\
  --logtostderr=false \\
  --allow-privileged=true \\
  --pod-manifest-path=/etc/kubernetes/manifests \\
  --cluster-dns=10.96.0.10 
  --cluster-domain=cluster.local \\
  --cgroup-driver=cgrpupfs \\
  --network-plugin=cni \\
  --cni-conf-dir=/etc/cni/net.d \\
  --cni-bin-dir=/opt/cni/bin \\"
mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF > /etc/systemd/system/kubelet.service.d/10-liyong.conf
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/
After=docker.service
Wants=docker.service

[Service]
EnvironmentFile=-/etc/kubernetes/kubelet.env
ExecStart=
ExecStart=/usr/bin/kubelet \\
  $base
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
kube::kubelet_config() 
{
  echo "生成kubelet.conf配置"
  KUBE_APISERVER="https://$MASTER_ADDR:6443"
 
  kubectl config set-cluster kubernetes \
      --server=${KUBE_APISERVER} \
      --insecure-skip-tls-verify=true \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config set-credentials kubelet-bootstrap \
      --client-certificate=/etc/kubernetes/ssl/kubelet.crt \
      --client-key=/etc/kubernetes/ssl/kubelet-key.pem \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=/etc/kubernetes/kubelet.conf

  kubectl config use-context default --kubeconfig=/etc/kubernetes/kubelet.conf
}

kube::master_config_cafile() {
  if [ ! -f "/etc/kubernetes/ssl/ca.pem" ]; then

  EXPIRY_YEAR=70
  EXPIRY_HOUR="$((EXPIRY_YEAR*8760))h"
  MASTER_IP=$(kube::getip)
  echo "生成TLS证书 master: $MASTER_ADDR, expiry year: $EXPIRY_YEAR"
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
    ], 
    "key": {
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
  cat <<EOF > /etc/kubernetes/ssl/kubelet-csr.json
{
    "CN":"admin",
    "key":{
        "algo":"rsa",
        "size":2048
    },
    "names":[{
        "C":"CN",
        "L":"ShenZhen",
        "ST":"ShenZhen",
        "O":"system:masters",
        "OU":"System"
    }]
}
EOF

  # config ssl
  rm -rf *.pem *.crt
  cd /etc/kubernetes/ssl
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
  mv ca.pem ca.crt
  cfssl gencert -ca=ca.crt -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
  mv kubernetes.pem kubernetes.crt
  cfssl gencert -ca=ca.crt -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubelet-csr.json | cfssljson -bare kubelet
  mv kubelet.pem kubelet.crt
  fi
}
kube::master_config_auth()
{
    mkdir -p /etc/kubernetes/auth
    local BOOTSTRAP_TOKEN="$(echo $MASTER_ADDR|md5sum|cut -f 1 -d ' ')"
    echo "123456,admin,admin" > /etc/kubernetes/auth/user.csv
}

kube::master_config_yaml()
{
    docker pull registry.cn-hangzhou.aliyuncs.com/k10/pause-amd64:3.1
    docker pull registry.cn-hangzhou.aliyuncs.com/k10/kube-apiserver-amd64:v1.10.5
    docker pull registry.cn-hangzhou.aliyuncs.com/k10/kube-scheduler-amd64:v1.10.5
    docker pull registry.cn-hangzhou.aliyuncs.com/k10/kube-controller-manager-amd64:v1.10.5
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
    image: registry.cn-hangzhou.aliyuncs.com/k10/kube-apiserver-amd64:v1.10.5
    command:
    - kube-apiserver
    # - --v=4
    - --apiserver-count=1
    - --insecure-port=8080
    - --insecure-bind-address=127.0.0.1
    - --secure-port=6443
    - --advertise-address=$master
    - --bind-address=0.0.0.0
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem
    - --tls-cert-file=/etc/kubernetes/ssl/kubernetes.crt
    - --client-ca-file=/etc/kubernetes/ssl/ca.crt
    - --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --authorization-mode=Node,RBAC
    - --anonymous-auth=true
    #- --basic-auth-file=/etc/kubernetes/auth/user.csv
    - --kubelet-https=true
    #- --enable-bootstrap-token-auth=true
    - --service-node-port-range=20000-60000
    - --admission-control=Initializers,NamespaceLifecycle,NamespaceExists,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultTolerationSeconds,NodeRestriction,DefaultStorageClass,ResourceQuota
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
    image: registry.cn-hangzhou.aliyuncs.com/k10/kube-scheduler-amd64:v1.10.5
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
    image: registry.cn-hangzhou.aliyuncs.com/k10/kube-controller-manager-amd64:v1.10.5
    command:
    - kube-controller-manager
    - --leader-elect=true
    - --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --root-ca-file=/etc/kubernetes/ssl/ca.crt
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
 
kube::install_master()
{
    kube::install_docker
    kube::install_kubelet
    kube::download_cfssl
    kube::master_config_cafile
    kube::master_config_auth
    kube::kubelet_config
    kube::master_config_yaml

    systemctl restart kubelet
}
 
kube::install_node()
{
    kube::install_docker
    kube::install_kubelet
    kube::kubelet_config

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
    *)
        echo "usage: $0 m[master] | e[etcd] | n[node] | k[kubelet] | d[docker] | t[token]"
        echo "       $0 master      to setup master "
        echo "       $0 etcd        to setup etcd "
        echo "       $0 node        to setup node "
        echo "       $0 kubelet     to setup kubelet "
        echo "       $0 docker      to setup docker "
        echo "       unkown command $0 $@"
        ;;
    esac
}

main $@