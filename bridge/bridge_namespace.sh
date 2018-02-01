#!/bin/sh

#使用 bridge 连接不同的 namespace

#创建bridge
ip link add br0 type bridge
ip link set dev br0 up
ip addr add 10.0.1.1/24 dev br0
###########################
#创建veth设备对
ip link add veth2 type veth peer name veth22
#创建namespace
ip netns add net2
ip link set dev veth22 netns net2
#添加到net0
ip netns exec net2 ip link set lo up
ip netns exec net2 ip link set dev veth22 name eth0
ip netns exec net2 ip addr add 10.0.1.2/24 dev eth0
ip netns exec net2 ip link set dev eth0 up
#ip netns exec net2 ip route add default dev eth0
ip netns exec net2 ip route add default via 10.0.1.1 dev eth0
#链接到bridge
ip link set dev veth2 master br0
ip link set dev veth2 up
###########################
#创建veth设备对
ip link add veth3 type veth peer name veth33
#创建namespace
ip netns add net3
ip link set dev veth33 netns net3
#添加到net0
ip netns exec net3 ip link set lo up
ip netns exec net3 ip link set dev veth33 name eth0
ip netns exec net3 ip addr add 10.0.1.3/24 dev eth0
ip netns exec net3 ip link set dev eth0 up
#ip netns exec net3 ip route add default dev eth0
ip netns exec net3 ip route add default via 10.0.1.1 dev eth0
#链接到bridge
ip link set dev veth3 master br0
ip link set dev veth3 up
############################
ip netns exec net2 ping 10.0.1.3
ip netns exec net3 ping 10.0.1.2

