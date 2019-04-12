#!/bin/bash

../install_common.sh

# 创建配置
cat <<EOF > k8sconfig.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: v1.12.7
imageRepository: registry.cn-hangzhou.aliyuncs.com/google-kubernetes
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.240.0.0/16"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
failSwapOn: false
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
clusterCIDR: "10.244.0.0/16"
EOF
 
# 安装Master
kubeadm init --config=k8sconfig.yaml --ignore-preflight-errors="Swap"