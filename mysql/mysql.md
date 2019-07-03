yum install -y mysql-community-common-5.7.26-1.el7.x86_64.rpm 
yum install -y mysql-community-libs-5.7.26-1.el7.x86_64.rpm 
yum install -y mysql-community-client-5.7.26-1.el7.x86_64.rpm
yum install -y mysql-community-server-5.7.26-1.el7.x86_64.rpm 

# 添加账号
use mysql;
insert into user (user,password) values('admin'，'Dev@123456');
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'Dev@123456' WITH GRANT OPTION;

# 主库
# 配置/etc/my.cnf
init_connect='SET collation_connection = utf8mb4_unicode_ci'
init_connect='SET NAMES utf8mb4'
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
skip-character-set-client-handshake
 
server-id=2
log-bin=mysql-bin
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
binlog-do-db=test


# 创建用于主从同步的账户

mysql -uroot -p
create user 'sync'@'%' identified by 'Sync!0000';
grant FILe on *.* to 'sync'@'%' identified by 'Sync!0000';
grant replication slave on *.* to 'sync'@'%' identified by 'Sync!0000';
flush privileges;

# 重启mysql
# 检查
show master status;

# 从库
# 配置/etc/my.cnf
init_connect='SET collation_connection = utf8mb4_unicode_ci'
init_connect='SET NAMES utf8mb4'
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
skip-character-set-client-handshake
 
server-id=3
log-bin=mysql-bin
replicate-ignore-db=mysql
replicate-ignore-db=information_schema
replicate-ignore-db=performance_schema
replicate-ignore-db=sys
log-slave-updates
slave-skip-errors=all     #屏蔽错误
slave-net-timeout=60

# 然后进入MySQL

show variables like 'server_id'; 
stop slave;
change master to master_host='10.11.46.201', master_user='sync',master_log_file='mysql-bin.000003',master_password='Sync!0000', master_log_pos=3812;

start slave;
show slave status;



========
# ProxySQL https://github.com/malongshuai/proxysql/wiki
 
# 添加软件源
cat <<EOF | tee /etc/yum.repos.d/proxysql.repo
[proxysql_repo]
name= ProxySQL
baseurl=http://repo.proxysql.com/ProxySQL/proxysql-2.0.x/centos/\$releasever
gpgcheck=1
gpgkey=http://repo.proxysql.com/ProxySQL/repo_pub_key
EOF

# 安装
yum -y install proxysql

# 启动
/etc/init.d/proxysql start

# mysql client
yum install -y mariadb.x86_64 mariadb-libs.x86_64

# 登录
mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> '
# 修改配置
use main;
delete from mysql_servers;

INSERT INTO mysql_servers (hostgroup_id,hostname) VALUES (1,'10.11.46.201');
INSERT INTO mysql_servers (hostgroup_id,hostname) VALUES (2,'10.11.46.202');

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;



UPDATE global_variables SET variable_value='root' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='Dev@123456' WHERE variable_name='mysql-monitor_password';

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;


delete  from mysql_users;

INSERT INTO mysql_users(username,password,default_hostgroup,transaction_persistent) VALUES ('root','Dev@123456',1,0);

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;


delete from mysql_query_rules;

INSERT INTO mysql_query_rules (rule_id,active,match_pattern,destination_hostgroup,apply) VALUES (1,1,'/\*(\s*)FORCE_MASTER(\s*)\*/',1,1);
INSERT INTO mysql_query_rules (rule_id,active,match_pattern,destination_hostgroup,apply) VALUES (2,1,'^(\s*)|(\s*/\*.*\*/\s*)SELECT',2,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;


select * from stats.stats_mysql_query_rules;
select * from stats.stats_mysql_commands_counters;
select * from stats.stats_mysql_processlist;