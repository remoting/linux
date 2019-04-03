cd ~ && mkdir certs && cd certs
openssl genrsa -des3 -passout pass:x -out dashboard.pass.key 2048
openssl rsa -passin pass:x -in dashboard.pass.key -out dashboard.key
openssl req -new -key dashboard.key -out dashboard.csr
openssl x509 -req -sha256 -days 365 -in dashboard.csr -signkey dashboard.key -out dashboard.crt
kubectl delete secret kubernetes-dashboard-certs -n kube-system
kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs -n kube-system
kubectl get pods -o wide -n kube-system
kubectl delete pod kubernetes-dashboard-d7f7b7776-lsk68 -n kube-system
kubectl get pods -o wide -n kube-system



kubectl create secret docker-registry regcred --docker-server=http://registry.dev.chelizitech.com --docker-username=xxx --docker-password=xxx --docker-email=r@y.cn



kubectl get secrets --all-namespaces
kubectl describe secrets kube-admin-token-fbbfv -n kube-system