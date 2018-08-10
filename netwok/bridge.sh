ip link add br0 type bridge
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 local 192.168.40.186 dev ens33
ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up
ip addr add 10.1.1.1/24 dev br0

ip netns add container1
# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up
# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.1.1.2/24 dev eth0
ip netns exec container1 ip link set eth0 up
 
======
ip link add br0 type bridge
ip link add vxlan0 type vxlan id 42 dstport 4789 group 239.1.1.1 local 192.168.40.150 dev ens33
ip link set vxlan0 master br0
ip link set vxlan0 up
ip link set br0 up
ip addr add 10.1.2.1/24 dev br0

ip netns add container1
# 创建 veth pair，并把一端加到网桥上
ip link add veth0 type veth peer name veth1
ip link set dev veth0 master br0
ip link set dev veth0 up
# 配置容器内部的网络和 IP
ip link set dev veth1 netns container1
ip netns exec container1 ip link set lo up
ip netns exec container1 ip link set veth1 name eth0
ip netns exec container1 ip addr add 10.1.2.2/24 dev eth0
ip netns exec container1 ip link set eth0 up
ip netns exec container1 ip route add default dev eth0


============
ip link add vxlan0 type vxlan id 100 dev ens33 dstport 4789 group 239.1.1.1 local 192.168.40.150
ip link set vxlan0 up

brctl addbr br0
ip link set dev br0 up
brctl addif vxlan0
brctl addif br0 vxlan0
#bridge fdb append to 00:00:00:00:00:00 dev vxlan0 dst 10.0.56.18








