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