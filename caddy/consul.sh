#!/bin/bash
cd `dirname $0`
consul::reg()
{
    local consul_addr=$1
    local str_name=$2
    local str_ip=$3
    local str_port=$4
    local srv_config=`cat <<EOF
    { 
        "name": "$str_name",
        "address": "$str_ip",
        "port": $str_port,
        "meta":{
            "sss":"1"
        },
        "checks": [
            {
                "DeregisterCriticalServiceAfter":"3m",
                "tcp": "$str_ip:$str_port",
                "interval": "15s",
                "timeout": "5s"
            }
        ]
    }
EOF`
    echo "注册服务:$srv_config" 
    curl -H "X-Consul-Token: 60a97597-fce3-433a-932d-22c850e92df1" -s -L http://$consul_addr:8500/v1/agent/service/register -XPUT -d "${srv_config}"
}

consul::reg $@
