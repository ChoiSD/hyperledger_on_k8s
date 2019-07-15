#!/bin/bash
kubectl apply -f storageClass.yaml
kubectl apply -f persistentVolume.yaml

cd ./hyperledger-fabric-org
echo "###### Start Org1 ######"
sed -i 's/org2/org1/g' *.yaml
sed -i 's/Org2/Org1/g' *.yaml
for yaml in $(ls)
do
  kubectl apply -f ${yaml}
done
kubectl get all -n org1

echo "###### Start Org2 ######"
sed -i 's/org1/org2/g' *.yaml
sed -i 's/Org1/Org2/g' *.yaml
for yaml in $(ls)
do
  kubectl apply -f ${yaml}
done
kubectl get all -n org2

echo "###### Start Orderer ######"
cd ../hyperledger-fabric-orderer
for yaml in $(ls *.yaml)
do
  kubectl apply -f ${yaml}
done
kubectl get all -n orderer

