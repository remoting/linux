README.txt

./consul.sh del 10.0.91.169 cloud-service-compute
./consul.sh del 10.0.91.169 cloud-service-image
./consul.sh del 10.0.91.169 cloud-service-network
./consul.sh del 10.0.91.169 cloud-service-volume

./consul.sh reg 10.0.91.169 cloud-service-compute 10.0.91.153 8774
./consul.sh reg 10.0.91.169 cloud-service-image 10.0.91.153 9292
./consul.sh reg 10.0.91.169 cloud-service-network 10.0.91.153 9696
./consul.sh reg 10.0.91.169 cloud-service-volume 10.0.91.153 8776
