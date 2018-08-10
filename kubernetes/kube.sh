KUBE_APISERVER="https://10.0.91.243:6443"
BOOTSTRAP_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJnaXRsYWItY2kiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiYWRtaW4tdG9rZW4tcmJtbDUiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYWRtaW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI0ZWU2NjUyMi04OTYwLTExZTgtODVhYi0wMDUwNTY4YWM1YTMiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6Z2l0bGFiLWNpOmFkbWluIn0.PiLo5Y92hSPg8y-2CBt-otM6Pq7o-_Tdzs-zMv9S_MoZVLiPjk1cUugosXt94Re66SQ856aIKBt48bTr_DK9UNsLtr0lT7PJCfHrbpEOSnHI0AYCrJIhjR9T6dyobgpF0-2ZEAY7hqS73VRxHiRtyt7Ihp1jB8mAchVkEK7G0CEk3mMWVVKLCDsDyt8V6Yo94Ujv-fhln25ao5pDqgtt4MooeIyHRIeUgoRkyXaTlVkeJmvMfOfmz3EcK8d2wnsIm-dR8ffgR8C9EGMXt7QTgwWsEGSsf2Md-WO9VpgNJAUq8zMskOtT83XeRwn3Sy7x3tYlPuafxPlFECWKQqEEKg"

kubectl config set-cluster kubernetes \
    --server=${KUBE_APISERVER} \
    --insecure-skip-tls-verify=true \
    --kubeconfig=./kubelet.conf

kubectl config set-credentials kubelet-bootstrap \
    --token=${BOOTSTRAP_TOKEN} \
    --kubeconfig=./kubelet.conf

kubectl config set-context default \
    --cluster=kubernetes \
    --user=kubelet-bootstrap \
    --kubeconfig=./kubelet.conf

kubectl config use-context default --kubeconfig=./kubelet.conf
