#!/bin/bash 
yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/pool/a68b4fbdee8689c7f78dab3fcbcfbc13eac7d7aa1eb708c313ab9a80512b6a0a-kubectl-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/583cdf9a7d7fe76b4b05ac00ff57d902b4c276fe98b3cbe0e696afcbdfd0e456-kubelet-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/a7aaf0551faafa396a9b69a961486486430b91be00fe0034cfd5aa9a4f56298c-kubeadm-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/548a0dcd865c16a50980420ddfa5fbccb8b59621179798e6dc905c9bf8af3b34-kubernetes-cni-0.7.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/e253c692a017b164ebb9ad1b6537ff8afd93c35e9ebc340a52c5bd42425c0760-cri-tools-1.11.0-0.x86_64.rpm

echo "KUBELET_EXTRA_ARGS=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-kubernetes/pause:3.1 --fail-swap-on=false" > /etc/sysconfig/kubelet

# 重启Docker 
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet