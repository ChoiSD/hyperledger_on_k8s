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

- ~~Make for Orderer Org~~

- Enable Orderer cluster (Kafka & Raft)

- Make CouchDB version

- Enable TLS (mutual TLS also)

- Make helm version

### Command

Org1 - Create & Join a channel

```bash
kubectl exec -it cli -n org1 -- mkdir /root/msp/admincerts
kubectl exec -it cli -n org1 -- cp /root/msp/signcerts/cert.pem /root/msp/admincerts/
kubectl exec -it cli -n org1 -- cp /root/artifacts/channel.tx /root/channel.tx
kubectl exec -it cli -n org1 -- peer channel create -c testchannel -f /root/channel.tx -o orderer-0.orderer.orderer:7050
kubectl exec -it cli -n org1 -- peer channel join -b testchannel.block
```

Org2 - Join a channel

```bash
kubectl exec -it cli -n org2 -- mkdir /root/msp/admincerts
kubectl exec -it cli -n org2 -- cp /root/msp/signcerts/cert.pem /root/msp/admincerts/
kubectl exec -it cli -n org2 -- peer channel fetch 0 -c testchannel -o orderer-0.orderer.orderer:7050
kubectl exec -it cli -n org2 -- peer channel join -b testchannel_0.block
```

Install & Instantiate a chaincode

```bash
# Install chaincode in Org1
kubectl cp chaincode_example org1/cli:chaincode_example
kubectl exec -it cli -n org1 -- mkdir -p /opt/gopath/src/chaincode_example
kubectl exec -it cli -n org1 -- cp chaincode_example/*.go /opt/gopath/src/chaincode_example
kubectl exec -it cli -n org1 -- peer chaincode install -n mycc -v 1.0 -p chaincode_example
# Install chaincode in Org2
kubectl cp chaincode_example org2/cli:chaincode_example
kubectl exec -it cli -n org1 -- mkdir -p /opt/gopath/src/chaincode_example
kubectl exec -it cli -n org1 -- cp chaincode_example/*.go /opt/gopath/src/chaincode_example
kubectl exec -it cli -n org1 -- peer chaincode install -n mycc -v 1.0 -p chaincode_example
# Instantiate chaincode
kubectl exec -it cli -n org1 -- peer chaincode instantiate -o orderer-0.orderer.orderer:7050 -C testchannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND('Org1.peer','Org2.peer')"
```

Query chaincode 

```bash
kubectl exec -it cli -n org1 -- peer chaincode query -C testchannel -n mycc -c '{"Args":["query","a"]}'
```