#!/usr/bin/env bash

#需要备份的目录
folder=/var/lib/jenkins
#scp远程目录
remote_folder=root@x.x.x.x:/home/backup/jenkins
#日志文件目录
logFile=/tmp/jenkins-bk.log

nowDate=$(date '+%Y%m%d%H%M%S')

backupName=Jenkins-backup-$nowDate.tar.gz

cd $folder

tar -zcvf $backupName jobs users config.xml plugins credentials.xml /secrets/master.key /secrets/hudson.util.Secret

sleep 3

scp -r $backupName $remote_folder

echo "Jenkins备份完毕-$backupName" >> $logFile

rm -f $backupName