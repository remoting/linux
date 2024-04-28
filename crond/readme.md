crontab -e

# 配置文件保存位置
/var/spool/cron/${USER}

# 表达式测试
https://tool.lu/crontab/

# 每分钟执行
*/1 * * * *

# 日志文件
debian 12 需要安装 rsyslog 服务
cat /var/log/cron.log

# LINUX获得当前用户名
- 办法1  whoami
- 办法2  ${USER}
 
# 样例定时任务代码

```
#!/bin/bash
cd `dirname $0`
source /etc/profile
source ~/.bashrc
mkdir -p ./logs
current_datetime=$(date +'%Y-%m-%d %H:%M:%S')
filename=$(date +'%Y%m%d%H%M%S')
echo $current_datetime > "./logs/$filename.txt"
```