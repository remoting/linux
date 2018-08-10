README.txt

./consul.sh del 10.0.91.169 cloud-service-compute
./consul.sh del 10.0.91.169 cloud-service-image
./consul.sh del 10.0.91.169 cloud-service-network
./consul.sh del 10.0.91.169 cloud-service-volume

./consul.sh reg 10.0.91.169 cloud-service-compute 10.0.91.153 8774
./consul.sh reg 10.0.91.169 cloud-service-image 10.0.91.153 9292
./consul.sh reg 10.0.91.169 cloud-service-network 10.0.91.153 9696
./consul.sh reg 10.0.91.169 cloud-service-volume 10.0.91.153 8776

➜  consul cat /usr/local/etc/consul/consul.json

./consul.sh reg 10.0.91.169 cloud-service-compute 10.0.91.153 8774
./consul.sh reg 10.0.91.169 cloud-service-image 10.0.91.153 9292
./consul.sh reg 10.0.91.169 cloud-service-network 10.0.91.153 9696
./consul.sh reg 10.0.91.169 cloud-service-volume 10.0.91.153 8776
./consul.sh reg 10.0.91.169 cloud-service-identity 10.0.91.153 5000

集群搭建
https://www.cnblogs.com/shanyou/p/6286207.html
 node001 
 ./consul agent -server -bootstrap-expect 2 -data-dir=data -node=n1 -bind=10.0.0.5 -client=0.0.0.0 &
 
 node002
 ./consul agent -server -bootstrap-expect 2 -data-dir=data -node=n2 -bind=10.0.0.6 -client=0.0.0.0 &
 ./consul join 10.0.0.5
 node003
 ./consul agent -server -bootstrap-expect 2 -data-dir=data -node=n3 -bind=10.0.0.7 -client=0.0.0.0 &
 ./consul join 10.0.0.5