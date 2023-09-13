# Mac 系统安装Docker客户端
https://download.docker.com/mac/static/stable/x86_64/

19.03.5


docker context create test --docker host=tcp://x.x.x.x:2375
docker context use test

yum install -y --nogpgcheck https://mirrors.aliyun.com/docker-ce/linux/centos/8.6/x86_64/stable/Packages/docker-ce-19.03.15-3.el8.x86_64.rpm https://mirrors.aliyun.com/docker-ce/linux/centos/8.6/x86_64/stable/Packages/containerd.io-1.3.9-3.1.el8.x86_64.rpm https://mirrors.aliyun.com/docker-ce/linux/centos/8.6/x86_64/stable/Packages/docker-ce-cli-19.03.15-3.el8.x86_64.rpm
