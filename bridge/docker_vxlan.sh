#node1
IF_NAME=ens33
LOCAL_IP=192.168.40.150
VNI=20
SUBNET=10.$VNI.0.0/16
SUBNETID=1
ip link add vxlan0 type vxlan id $VNI dstport 4789 local $LOCAL_IP dev $IF_NAME nolearning #group 239.1.1.1
ip addr add 10.20.$SUBNETID.0/32 dev vxlan0
ip link set vxlan0 up 
ip route add $SUBNET dev vxlan0 scope global
echo '3' > /proc/sys/net/ipv4/neigh/vxlan0/app_solicit

#node2
IF_NAME=ens33
LOCAL_IP=192.168.40.151
VNI=20
SUBNET=10.$VNI.0.0/16
SUBNETID=2
ip link add vxlan0 type vxlan id $VNI dstport 4789 local $LOCAL_IP dev $IF_NAME nolearning #group 239.1.1.1
ip addr add 10.20.$SUBNETID.0/32 dev vxlan0
ip link set vxlan0 up 
ip route add $SUBNET dev vxlan0 scope global
echo '3' > /proc/sys/net/ipv4/neigh/vxlan0/app_solicit

#=======================
#=======================
#=======================
#=======================
#=======================
#node1
VTEP_MAC=ba:60:5d:d0:39:c0
bridge fdb add $VTEP_MAC dev vxlan0 dst 192.168.40.151 
ip neighbor add 10.20.2.0 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.2.1 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.2.2 lladdr $VTEP_MAC dev vxlan0

#node2
VTEP_MAC=f6:40:f5:2c:bf:78
bridge fdb add $VTEP_MAC dev vxlan0 dst 192.168.40.150 
ip neighbor add 10.20.1.0 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.1.1 lladdr $VTEP_MAC dev vxlan0
ip neighbor add 10.20.1.2 lladdr $VTEP_MAC dev vxlan0

##==============
/etc/sysctl.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tcat ables=1
net.ipv4.ip_forward=1

