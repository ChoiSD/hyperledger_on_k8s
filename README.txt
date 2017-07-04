1. apply custom-dns.yaml
2. Customize DNS flow (http://blog.kubernetes.io/2017/04/configuring-private-dns-zones-upstream-nameservers-kubernetes.html)
DNS_IP=`kubectl get svc/custom-dns -n hyperledger-k8s -o custom-columns="IP:.spec.clusterIP" | tail -1`


vi dns-flow.yaml
```````
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
data:
  stubDomains: |
    {"example.com": ["DNS_IP"]}
  upstreamNameservers: |
    ["8.8.8.8", "8.8.4.4"]
```````

kubectl delete configmap/kube-dns -n kube-system; kubectl create -f dns-flow.yaml
kubectl delete $(kubectl get po -n kube-system -o name -l k8s-app=kube-dns) -n kube-system

3. Apply hyperledger-k8s.yaml
kubectl apply -f hyperledger-k8s.yaml


4. Edit custom dns server's config
echo -e "; -----------------------------------------------------------------------------\n; hyperledger-k8s\n; -----------------------------------------------------------------------------" | tee -a dns/example.com.zone
kubectl get svc -n hyperledger-k8s -o custom-columns="Name:.metadata.name,IP:.spec.clusterIP" | sed 1d | sed 's/\-/\./g' | awk '{print $1 "\t1800\tIN\tA\t" $2}' | tee -a dns/example.com.zone
gcloud compute scp
kubectl delete po -n hyperledger-k8s -l fabric=internal-dns

5. Add 'docker0' bridge
docker create network docker0
# check bridge device name & IP address
ip link set dev <device name> down
brctl delbr <device name>
brctl addbr docker0
ip addr add <ip address>/16 dev docker0
ip link set dev docker0 up
