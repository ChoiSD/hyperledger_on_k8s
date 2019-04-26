# Deploy Hyperledger Fabric on k8s

This repository is for deploying hyperledger fabric on k8s cluster.

Before starting, I considered of following things:

- Hyperledger Fabric is an enterprise-grade blockchain solution, and it is developed to intend incorporating certified members(Organizations) in a blockchain network.

- All members will manage their own peers.

So I divided this guide into few steps. One for peer Organization, and one for orderer Organization.
~~Leave multiple organizations for Orderer behind at this time~~
