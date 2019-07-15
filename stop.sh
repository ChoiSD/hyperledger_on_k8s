#!/bin/bash
for namespace in orderer org1 org2
do
  kubectl delete namespace ${namespace}
done

kubectl delete job.batch/genesis-block
kubectl delete configmaps/configtx

kubectl delete -f ./persistentVolume.yaml
kubectl delete -f ./hyperledger-fabric-orderer/03-clusterrole.yaml

echo "## Now delete data in Persistent Volume ##"
