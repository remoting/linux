#!/bin/bash

../install_common.sh

# 主节点添加token
# kubeadm token create --print-join-command

# Node节点加入集群，命令行里面的内容是上一个命令的返回
kubeadm join  xxxxxxx --ignore-preflight-errors="Swap"