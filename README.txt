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

5. Edit docker service
sed -i 's/^DOCKER_OPTS/DOCKER_OPTS\=\"\-\-bridge\=cbr0 \-\-iptables\=false \-\-ip-masq\=false\"/g' /etc/init.d/docker
service docker restart

6. Do e2e example
export CHANNEL_NAME=mychannel
peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel join -b mychannel.block
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
