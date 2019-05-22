# Deploy Hyperledger Fabric on k8s

This repository is for deploying hyperledger fabric on k8s cluster.

Before starting, I considered of following things:

- Hyperledger Fabric is an enterprise-grade blockchain solution, and it is developed for incorporating many certified members(Organizations) in a blockchain network.

- All members will manage their own peers.

So I divided this guide into few steps. One for peer Organization, and one for orderer Organization.
*Leave multiple-organization configuration for Orderer behind at this time*

## Things to do

- ~~Enroll with bootstrap user and make it as a secret~~

- ~~Register peers' identity~~

- ~~Enroll with peer's identity and get certificates in a persistent volume~~

- ~~Deploy peers as a StatefulSet~~

- Make for Orderer Org

### Command

```bash
curl -sSL http://bit.ly/2ysbOFE | bash -d -s u
mkdir -p {orderer,org1,org2}/{cacerts,admincerts}
kubectl get secret/admin -n org1 -o json | ./jq -r '.data.CA' | base64 -d > org1/cacerts/ca.pem
kubectl get secret/admin -n org1 -o json | ./jq -r '.data.cert' | base64 -d > org1/admincerts/admin.pem
kubectl get secret/admin -n org2 -o json | ./jq -r '.data.CA' | base64 -d > org2/cacerts/ca.pem
kubectl get secret/admin -n org2 -o json | ./jq -r '.data.cert' | base64 -d > org2/admincerts/admin.pem
kubectl get secret/admin -n orderer -o json | ./jq -r '.data.CA' | base64 -d > orderer/cacerts/ca.pem
kubectl get secret/admin -n orderer -o json | ./jq -r '.data.cert' | base64 -d > orderer/admincerts/admin.pem

./bin/configtxgen -configPath $PWD -profile OrdererGenesis -channelID syschannel -outputBlock genesis.block
kubectl create secret generic genesis -n orderer --from-file=./genesis.block

kubectl apply -f orderer.yaml

./bin/configtxgen -configPath $PWD -profile OrgsChannel -channelID channel1 -outputCreateChannelTx channel1.tx 
./bin/configtxgen -configPath $PWD -profile OrgsChannel -channelID channel1 -outputAnchorPeersUpdate Org1channel1.tx -asOrg Org1
./bin/configtxgen -configPath $PWD -profile OrgsChannel -channelID channel1 -outputAnchorPeersUpdate Org2channel1.tx -asOrg Org2

kubectl cp channel1.tx org1/cli:/root/channel1.tx
kubectl exec -it cli -n org1 -- peer channel signconfigtx -f /root/channel1.tx 
kubectl cp org1/cli:/root/channel1.tx channel1-SignByOrg1.tx
kubectl cp channel1-SignByOrg1.tx org2/cli:/root/channel1.tx
kubectl exec -it cli -n org2 -- peer channel create -o orderer-0.orderer.orderer:7050 -c channel1 -f /root/channel1.tx

kubectl cp Org1channel1.tx org1/cli:/root/Org1channel1.tx
```