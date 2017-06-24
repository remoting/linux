## 基本安装
yum install -y openldap-servers openldap-clients
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/DB_CONFIG

## 启动服务
systemctl start slapd 
systemctl enable slapd
systemctl status slapd

## 生产密码
slappasswd -s 123456
{SSHA}InKgLWWY34U6ITWVWO9OqUltPvHkNk7x

## 修改更密码
ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

## 导入基本的schema
ls /etc/openldap/schema/*.ldif | while read f; do ldapadd -Y EXTERNAL -H ldapi:/// -f $f; done

## 修改根域
ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif

## 创建根域 DN 信息
ldapadd -x -D cn=Manager,dc=openbridge,dc=cn -W -f basedomain.ldif

## 使用管理工具连接
http://www.ldapadministrator.com/download.htm
