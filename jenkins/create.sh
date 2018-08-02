#!/bin/bash
docker run -d --restart=always -e JAVA_OPTS=" -Duser.timezone=GMT+08 " -e http_proxy="http://10.1.30.95:8088" --name jenkins -p 80:8080 -p 50000:50000 -v /data/jenkins_home:/var/jenkins_home 10.0.56.31/ycloud/jenkins:yh-2