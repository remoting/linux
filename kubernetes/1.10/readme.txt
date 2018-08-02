sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "api-enable-cors": true,
  "api-cors-header": "*",
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
  "registry-mirrors": ["https://4ssmxahm.mirror.aliyuncs.com"],
  "insecure-registries": ["registry.yonghui.cn","10.0.56.31","10.0.56.31:80"]
}
EOF

---
[cmp-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.0.90.140]
---
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

   ip route add 10.244.1.0/24 via 172.16.211.128 dev ens33

   kubeadm join 172.16.211.131:6443 --token h10dsr.l16p0gc6j7nkxyrk --discovery-token-ca-cert-hash sha256:a97c5c4c1fe36e29910c71a8a9ae67fca5b15bbc70d898bf37aa7d83824ac91b --ignore-preflight-errors="Swap"