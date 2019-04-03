sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "api-enable-cors": true,
  "api-cors-header": "*",
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
  "registry-mirrors": ["https://4ssmxahm.mirror.aliyuncs.com"],
  "insecure-registries": ["registry.dev.chelizitech.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker