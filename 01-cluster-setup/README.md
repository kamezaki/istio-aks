# How to create aks cluster

## Install bicep in your local PC
Install `bicep CLI`. please see [bicep project page](https://github.com/Azure/bicep/blob/main/docs/installing.md)

## Before deploy aks on your azure enviroment
```
# You should login to azure first
az login

# Then you create your resource group in your subscription
az group create -n rg-istio-aks -l japaneast
```

## Build and deploy sample aks cluster

```
# build
bicep build istio-aks.bicep

# deploy
az deployment group create -f istio-aks.json -g rg-istio-aks
```