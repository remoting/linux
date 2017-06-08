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


## 安装基础软件
```
yum install -y git zip unzip vim wget
```