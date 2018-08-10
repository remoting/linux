#!/bin/bash

user=$(id -u)
echo "current user id: $user"

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
        "checks": [
            {
                "tcp": "$str_ip:$str_port",
                "interval": "15s",
                "timeout": "5s"
            }
        ]
    }
EOF`

    echo "注册服务:$srv_config" 
    curl -s -L http://$consul_addr:8500/v1/agent/service/register -XPUT -d "${srv_config}"

}

consul::del()
{
    local consul_addr=$1
    local str_name=$2
    echo "删除服务：$consul_addr $str_name"
    curl -XPUT "$consul_addr:8500/v1/agent/service/deregister/$str_name"
    
}
consul::dchk()
{
    local consul_addr=$1
    local str_name=$2
    echo "删除Check：$consul_addr $str_name"
    curl -XPUT "$consul_addr:8500/v1/agent/check/deregister/$str_name"

}
consul::clear()
{
    local consul_addr=$1
    local ids=`curl -s "$consul_addr:8500/v1/health/state/critical" | jq '.[]' | jq -r '.ServiceID'`
    for i in $ids; do
      consul::del $1 $i;
    done;
}
main()
{
    case $1 in
    "r" | "reg" )
        consul::reg $2 $3 $4 $5
        ;;
    "d" | "del" )
        consul::del $2 $3
        ;;
    "dc" | "dc" )
        consul::dchk $2 $3
        ;;
    "c" | "clear" )
        consul::clear $2
        ;;
    *)
        echo "usage: $0 reg | del | clear"
        echo "       $0 reg consulHost serviceName ip port "
        echo "       $0 del consulHost serviceName "
        echo "       $0 dc consulHost checkId "
        echo "       $0 clear consulHost "
        ;;
    esac
}
main $@