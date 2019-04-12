#!/bin/bash

yum install -y keepalived

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 35f18af7190d51c9f7f78f37300a0cbd
    }
    virtual_ipaddress {
        10.11.46.210
    }
    track_script {
        check_haproxy
    }
}
EOF

#
# master-0节点为***MASTER***，其余节点为***BACKUP***
# priority各个几点到优先级相差50，范围：0～250（非强制要求）
#

systemctl enable keepalived
systemctl start keepalived