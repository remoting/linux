#!/bin/bash
cd `dirname $0`
consul::getip() {
    host_ips=(`ip addr show|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|cut -f1 -d '/'`)
    if [ "${host_ips[0]}" == "" ]; then
        echo "[ERROR] get ip address error!"
        exit 1
    else
        echo "${host_ips[0]}"
    fi
}
consul::reg()
{
    local consul_addr=$SPRING_CLOUD_CONSUL_HOST 
    local consul_port=${SPRING_CLOUD_CONSUL_PORT:-"8500"}
    local consul_token=$SPRING_CLOUD_CONSUL_TOKEN
    local str_name=$1
    local str_path=$2
    local str_health=$2
    if [ "$3" != "" ] ;then
       str_health=$3
    fi
    local str_ip=$(consul::getip)
    local str_port=${CTL_SERVICE_PORT:-"80"}
    local srv_config=`cat <<EOF
    { 
        "id": "${str_name}-${str_ip//\./\-}",
        "name": "$str_name",
        "address": "$str_ip",
        "port": $str_port,
        "tags": ["contextPath=$str_path"],
        "checks": [
            {
                "DeregisterCriticalServiceAfter":"3m",
                "http": "http://$str_ip:$str_port$str_health",
                "interval": "15s",
                "timeout": "10s",
                "status": "passing"
            }
        ]
    }
EOF`
    echo "注册服务:consul $consul_addr:$consul_port,token $consul_token"
    echo "$srv_config" 
    curl -v --header "X-Consul-Token: $consul_token" http://$consul_addr:$consul_port/v1/agent/service/register -XPUT -d "${srv_config}"
}


sleep 3
consul::reg $1 $2 $3
