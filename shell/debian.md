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