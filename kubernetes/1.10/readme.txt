yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/Packages/docker-engine-selinux-1.13.1-1.el7.centos.noarch.rpm \
    http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/Packages/docker-engine-1.13.1-1.el7.centos.x86_64.rpm


yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/pool/1eed768852fa3e497e1b7bdf4e93afbe3b4b0fdcb59fda801d817736578b9838-kubectl-1.10.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/94d062f2d86b8f4f55f4d23a3610af25931da9168b7f651967c269273955a5a2-kubelet-1.10.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/fe33057ffe95bfae65e2f269e1b05e99308853176e24a4d027bc082b471a07c0-kubernetes-cni-0.6.0-0.x86_64.rpm

yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/pool/3ea9c50d098c50a7e968c35915d3d8af7f54c58c0cedb0f9603674720743de4e-kubeadm-1.10.5-0.x86_64.rpm

docker
	ExecStart=/usr/bin/dockerd --exec-opt native.cgroupdriver=systemd
kubelet
	ExecStart=/usr/bin/kubelet --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/k10/pause-amd64:3.1 --fail-swap-on=false

cat <<EOF > k8sconfig.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: v1.10.5
imageRepository: registry.cn-hangzhou.aliyuncs.com/k10
networking:
  podSubnet: 10.244.0.0/16
EOF

kubeadm reset

kubeadm init --config=k8sconfig.yaml --ignore-preflight-errors="Swap"

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 172.16.211.131:6443 --token h10dsr.l16p0gc6j7nkxyrk --discovery-token-ca-cert-hash sha256:a97c5c4c1fe36e29910c71a8a9ae67fca5b15bbc70d898bf37aa7d83824ac91b