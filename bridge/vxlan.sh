#===================
#node1
LOCAL_IP=192.168.40.186
REMOTE_IP=192.168.40.150
IF_NAME=ens33
ip link add vxlan0 type vxlan id 42 dstport 4789 remote $REMOTE_IP local $LOCAL_IP dev $IF_NAME 
ip addr add 10.20.1.2/24 dev vxlan0
ip link set vxlan0 up

#node2
LOCAL_IP=192.168.40.150
REMOTE_IP=192.168.40.186
IF_NAME=ens33
ip link add vxlan0 type vxlan id 42 dstport 4789 remote $REMOTE_IP local $LOCAL_IP dev $IF_NAME 
ip addr add 10.20.1.3/24 dev vxlan0
ip link set vxlan0 up

#===================
#node1
IF_NAME=ens33
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev $IF_NAME 
ip addr add 10.20.1.2/24 dev vxlan0
ip link set vxlan0 up

#node2
IF_NAME=ens33
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 dev $IF_NAME 
ip addr add 10.20.1.3/24 dev vxlan0
ip link set vxlan0 up

#====================
#node1
IF_NAME=ens33
LOCAL_IP=192.168.40.186
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 local $LOCAL_IP dev $IF_NAME 
ip link add br0 type bridge
ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up

ip netns add container1

# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up

# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.20.1.2/24 dev eth0
ip netns exec container1 ip link set eth0 up

#node2
IF_NAME=ens33
LOCAL_IP=192.168.40.150
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 local $LOCAL_IP dev $IF_NAME 
ip link add br0 type bridge
ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up

ip netns add container1

# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up

# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.20.1.3/24 dev eth0
ip netns exec container1 ip link set eth0 up













