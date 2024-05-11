#!/bin/bash
# 脚本功能 :  
# 脚本参数 :  主机名，例：pro-docker-111（IP第四位）
# 参数示例 :   
# ORGANIZATION :  BlueKing
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cur_dir=$(pwd)
gcc_version=`rpm -qa gcc | awk -F '[-]' '{print $2}'`

VERSION=`cat /etc/issue | grep '6.'`
if [ "$VERSION" == "" ];then
    VERSION='centos7'
else
    VERSION='centos6'
fi

#服务器安全配置
#确保rsyslog服务已启用，记录日志用于审计
yum install rsyslog -y
systemctl enable rsyslog
systemctl start rsyslog

#设置SSH空闲超时退出时间,可降低未授权用户访问其他用户ssh会话的风险
sed  -i 's/#ClientAliveInterval 0/ClientAliveInterval 600/g' /etc/ssh/sshd_config
sed  -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config
#确保SSH LogLevel设置为INFO,记录登录和注销活动
sed  -i 's/#LogLevel INFO/LogLevel INFO/g' /etc/ssh/sshd_config
#设置较低的Max AuthTrimes参数将降低SSH服务器被暴力攻击成功的风险
sed  -i 's/#MaxAuthTries 6/MaxAuthTries 4/g' /etc/ssh/sshd_config
#禁止SSH空密码用户登录 
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
#SSHD强制使用V2安全协议
echo "Protocol 2" >> /etc/ssh/sshd_config
service sshd restart


#更改ulimit参数
if [ "`cat /etc/security/limits.conf | grep 'soft nproc 65535'`" = "" ]; then
cat  >> /etc/security/limits.conf << EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
echo "ulimit -SHn 65535" >> /etc/profile
echo "ulimit -SHn 65535" >> /etc/rc.local
fi

#安装必要工具
yum update -y
yum install -y vim wget ntpdate sysstat wget man mtr lsof iotop net-tools openssl-devel openssl-perl iostat subversion nscd git

#关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

#设置ssh
sed -i "s/\#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 33031/g' /etc/ssh/sshd_config

#新建目录
mkdir -p /data/logs
mkdir -p /data/backup
mkdir -p /data/script
mkdir -p /data/local
mkdir -p /data/tools

#设置sysctl
rm -rf /etc/sysctl.conf 
echo "net.ipv4.ip_local_port_range = 1024 65535
kernel.shmall = 4294967296
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 30000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
fs.file-max = 655360
net.core.somaxconn = 65535
vm.swappiness = 10
vm.overcommit_memory = 1
fs.inotify.max_user_watches = 8192000
vm.overcommit_memory=1" >> /etc/sysctl.conf 



#"安装系统工具"
yum install -y gcc gcc-c++ make cmake autoconf bzip2 bzip2-devel curl openssl openssl-devel rsync gd zip perl unzip

#重启服务
#ssh
if [ "$VERSION" == "centos6" ]; then
    service sshd restart
    service iptables stop
    chkconfig iptables off
    /sbin/sysctl -p
else
    systemctl restart sshd
    systemclt disable postfix.service
    systemctl stop postfix.service
    systemctl stop firewalld
    systemctl disable firewalld
    systemctl mask firewalld
    yum install iptables-services -y
    /sbin/sysctl -p
fi
