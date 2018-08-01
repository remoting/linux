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
    curl -v -XPUT "$consul_addr:8500/v1/agent/service/deregister/$str_name"
    
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
    *)
        echo "usage: $0 reg | del"
        echo "       $0 reg consulHost serviceName ip port  "
        echo "       $0 del consulHost serviceName "
        ;;
    esac
}
main $@