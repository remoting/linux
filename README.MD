# 系统配置
sestatus

## 安装源
```
yum install epel-release
```

##### CentOS 5
```
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
```
##### CentOS 6
```
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
```
##### CentOS 7
```
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```
##### Debian 8 (jessie)
```
cat <<EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
EOF
apt-get update
```
##### Debian 9 (stretch)
```
cat <<EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib
deb http://mirrors.aliyun.com/debian/ stretch-proposed-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ stretch-proposed-updates main non-free contrib
EOF
apt-get update
```

## 安装基础软件
```
yum install -y git zip unzip vim wget

apt install -y git zip unzip vim wget
```