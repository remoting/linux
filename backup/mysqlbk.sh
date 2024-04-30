#!/usr/bin/env bash

#需要备份的目录
folder="/tmp/$(date '+%Y%m%d')"
mkdir -p $folder

#scp远程目录
remote_folder=root@192.168.18.245:/home/backup/mysql/

logFile=/tmp/mysqlback.log
  
host="xx"
username="xx"
password="xx"

for dbname in `mysql -h${host} -u${username} -p${password}  -e "show databases;" | grep -Evi 'Database|test|mysql|information_schema|performance_schema|seate'`
do
    echo "backup:$dbname"
    nowDate=$(date '+%Y%m%d%H%M%S')
    mysqldump -h${host} -u${username} -p${password} --set-gtid-purged=OFF -E -R -B $dbname | gzip > $folder/${dbname}-$nowDate.sql.gz
done

backupName="${folder}/mysql-backup-$(date '+%Y%m%d%H%M%S').tar"
tar -cvf $backupName $folder/*.sql.gz

sleep 3

scp -r $backupName $remote_folder

# #if [$? = 0];then
echo "mysql备份完毕-$nowDate" >> $logFile
rm -f $backupName
rm -f $folder/*.sql.gz
# #fi
 