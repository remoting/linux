#!/bin/bash

# 更新系统
yum update -y
yum install git zip unzip wget curl vim tree telnet ipvsadm -y

# 关闭SELinux
sed -i "s/=enforcing/=disabled/g" /etc/selinux/config

# 内核转发
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

# ipvs
./ipvs.sh

# 修改主机名
hostnamectl set-hostname node-00x

# 关闭防火墙
systemctl disable firewalld

# 安装Docker
yum install -y --nogpgcheck \
    https://mirrors.aliyun.com/docker-ce/linux/centos/7/x86_64/stable/Packages/docker-ce-18.06.3.ce-3.el7.x86_64.rpm

# 安装Kubelet
yum install -y --nogpgcheck \
    http://mirrors.aliyun.com/kubernetes/yum/pool/a68b4fbdee8689c7f78dab3fcbcfbc13eac7d7aa1eb708c313ab9a80512b6a0a-kubectl-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/583cdf9a7d7fe76b4b05ac00ff57d902b4c276fe98b3cbe0e696afcbdfd0e456-kubelet-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/a7aaf0551faafa396a9b69a961486486430b91be00fe0034cfd5aa9a4f56298c-kubeadm-1.12.7-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/548a0dcd865c16a50980420ddfa5fbccb8b59621179798e6dc905c9bf8af3b34-kubernetes-cni-0.7.5-0.x86_64.rpm \
    http://mirrors.aliyun.com/kubernetes/yum/pool/e253c692a017b164ebb9ad1b6537ff8afd93c35e9ebc340a52c5bd42425c0760-cri-tools-1.11.0-0.x86_64.rpm

echo "KUBELET_EXTRA_ARGS=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-kubernetes/pause:3.1 --fail-swap-on=false" > /etc/sysconfig/kubelet

# 重启Docker 
systemctl daemon-reload
systemctl enable docker
systemctl enable kubelet
systemctl restart docker
systemctl restart kubelet