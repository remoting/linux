yum -y remove mariadb-libs
tar -xf mysql-5.7.23-1.el7.x86_64.rpm-bundle.tar

yum install -y mysql-community-common-5.7.23-1.el7.x86_64.rpm 
yum install -y mysql-community-libs-5.7.23-1.el7.x86_64.rpm 
yum install -y mysql-community-client-5.7.23-1.el7.x86_64.rpm
yum install -y mysql-community-server-5.7.23-1.el7.x86_64.rpm 

cat /var/log/mysqld.log |grep password


2018-08-23T07:41:40.177039Z 1 [Note] A temporary password is generated for root@localhost: LT:fUr6:g&S7

[root@Geeklp-MySQL ~]# mkdir /home/data
[root@Geeklp-MySQL ~]# mv /var/lib/mysql /home/data/
[root@Geeklp-MySQL ~]# vi /etc/my.cnf
default-storage-engine=INNODB 
lower_case_table_names=1

#
mysql --socket=/data/mysql/mysql.sock -uroot -p

use mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'xxx';
GRANT ALL ON *.* to root@'%' IDENTIFIED BY 'xxx';
FLUSH PRIVILEGES;