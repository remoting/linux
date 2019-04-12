#!/bin/bash

../install_common.sh

# 创建配置
cat <<EOF > k8sconfig.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: v1.12.7
imageRepository: registry.cn-hangzhou.aliyuncs.com/google-kubernetes
controlPlaneEndpoint: "10.11.46.210:16443"
etcd:
  external:
    endpoints:
    - http://10.11.46.201:2379
    - http://10.11.46.202:2379
    - http://10.11.46.203:2379
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.240.0.0/16"
apiServerCertSANs:
  - "10.11.46.201"
  - "10.11.46.202"
  - "10.11.46.203"
  - "10.11.46.210"
apiServerExtraArgs:
  endpoint-reconciler-type: lease
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
failSwapOn: false
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
EOF
 
# 安装Master
kubeadm init --config=k8sconfig.yaml --ignore-preflight-errors="Swap"

scp -r /etc/kubernetes/pki root@10.11.46.202:/etc/kubernetes/
scp k8sconfig.yaml root@10.11.46.202:/root/

scp -r /etc/kubernetes/pki root@10.11.46.203:/etc/kubernetes/
scp k8sconfig.yaml root@10.11.46.203:/root/