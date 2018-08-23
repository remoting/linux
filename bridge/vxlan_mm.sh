#node1
IF_NAME=ens33
LOCAL_IP=192.168.40.150
SUBNETID=1
VNI=20
ip link add vxlan0 type vxlan id $VNI dstport 4789 local $LOCAL_IP dev $IF_NAME nolearning #group 239.1.1.1 
ip link add br0 type bridge
ip addr add 10.$VNI.$SUBNETID.1/24 dev br0
ip addr add 10.$VNI.$SUBNETID.0/32 dev vxlan0
#ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up
ip route add 10.$VNI.0.0/16 dev vxlan0 scope global

ip netns add container1

# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up

# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.$VNI.$SUBNETID.2/24 dev eth0
ip netns exec container1 ip link set eth0 up

#node2
IF_NAME=ens33
LOCAL_IP=192.168.40.151
SUBNETID=2
VNI=20
ip link add vxlan0 type vxlan id $VNI dstport 4789 local $LOCAL_IP dev $IF_NAME nolearning #group 239.1.1.1 
ip link add br0 type bridge
ip addr add 10.$VNI.$SUBNETID.1/24 dev br0
ip addr add 10.$VNI.$SUBNETID.0/32 dev vxlan0
#ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up
ip route add 10.$VNI.0.0/16 dev vxlan0 scope global

ip netns add container1

# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up

# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.$VNI.$SUBNETID.2/24 dev eth0
ip netns exec container1 ip link set eth0 up


#node1
VTEP_MAC=be:96:fc:7e:5e:4f
#bridge fdb add $VTEP_MAC dev vxlan0 dst 192.168.40.151 
ip neighbor add 10.20.2.0 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.2.1 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.2.2 lladdr $VTEP_MAC dev vxlan0

#node2
VTEP_MAC=9e:2c:29:f3:f3:d1
#bridge fdb add $VTEP_MAC dev vxlan0 dst 192.168.40.150 
ip neighbor add 10.20.1.0 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.1.1 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.1.2 lladdr $VTEP_MAC dev vxlan0
