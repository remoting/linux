KUBE_APISERVER="https://10.0.90.27:6443"
BOOTSTRAP_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tcXh2OTYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjY2M2UxNjE3LTZkMjUtMTFlOC05NDM3LTAwNTA1NjhhMmM0OSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.fo-Af-hlD2Oj6ONVJA-6zHJpL2XDAMprLbGRAsYtLuOH4euZZckdT83uJAqb-N3D1RjUS32b9K4-ZJXncGGIYrvVPQtAotoNX71YA3gL-IOkj3BVdrBMslZFzGEV7334s34gfcKEHOJ1EPIlHgAHnOeAPE-UobNFUDZftuCw9pCz4BHtaAdAXzGkIbWejERdiLGJoPvJQVyNxToU1whLlFC-vCEjpx3MpHqPxxXfjU3L78yBFciQsmxdRIZpY4ETrfDpQpnuqzs6XENxUwFtFmELaAOIK9uR1fukxLlO5frT2-gZPxbAyEQMJd825Wp97t3L6pq_7iocSgbj9TrN-g"

kubectl config set-cluster haozhi-k8s \
    --server=${KUBE_APISERVER} \
    --insecure-skip-tls-verify=true \
    --kubeconfig=/Users/liyong/.kube/config

kubectl config set-credentials haozhi-k8s-token \
    --token=${BOOTSTRAP_TOKEN} \
    --kubeconfig=/Users/liyong/.kube/config

kubectl config set-context haozhi \
    --cluster=haozhi-k8s \
    --user=haozhi-k8s-token \
    --kubeconfig=/Users/liyong/.kube/config