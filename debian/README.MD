# 安装zsh

```
apt install -y zsh
 

git clone --depth 1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc


chsh -s zsh



 

git config --global user.name "remoting"
git config --global user.email "remoting@qq.com"



#!/bin/bash

# sources
cat <<EOF > /etc/apt/sources.list
deb http://mirrors.163.com/debian/ bullseye main
deb-src http://mirrors.163.com/debian/ bullseye main
deb http://mirrors.163.com/debian-security bullseye-security main
deb-src http://mirrors.163.com/debian-security bullseye-security main
deb http://mirrors.163.com/debian/ bullseye-updates main
deb-src http://mirrors.163.com/debian/ bullseye-updates main
EOF

# timezone
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# base tools
apt-get update
apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl wget vim gnupg2 iproute2 tree git procps bash-completion




# 添加基础工具
apt-get install software-properties-common

# 信任 Docker 的 GPG 公钥
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# 添加软件园
add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"

# 按照Docker
apt update
apt install docker-ce
```