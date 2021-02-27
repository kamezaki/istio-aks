// originally from: https://github.com/Azure/bicep/blob/fef0778170033b005b188ac140c04586ff39f4a0/docs/examples/101/aks-vmss-systemassigned-identity/main.bicep

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Specifies the Azure location where the key vault should be created.'
  }
}
param clusterName string {
  default: 'sample-with-istio'
  metadata: {
    description: 'The name of the Managed Cluster resource.'
  }
}
param defaultAgentPoolName  string {
  default: 'default-pool'
  metadata: {
    description: 'The name of the default agent pool name.'
  }
}
param agentCount int {
  default: 1
  minValue: 1
  maxValue: 50
  metadata: {
    description: 'The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production'
  }
}
param agentVMSize string {
  default: 'Standard_D2_v3'
  metadata: {
    description: 'The size of the Virtual Machine.'
  }
}

// Azure Kubernetes Service configurations
var kubernetesVersion = '1.19.0'
var nodeResourceGroup = 'rg-${clusterName}-aks'

// virtual network configurations
var virtualNetworkName = 'vnet-${clusterName}-${location}'
var addressPrefix =  '172.30.0.0/16'
var subnetName = 'subnet-${clusterName}-k8s-${location}'
var subnetPrefix = '172.30.0.0/24'
var subnetRef = '${vn.id}/subnets/${subnetName}'

// common configurations
var tags = {
  environment: 'validation'
} 

// Azure virtual network
resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

// Azure kubernetes service
resource aks 'Microsoft.ContainerService/managedClusters@2020-12-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    servicePrincipalProfile: {
      clientId: 'msi'   // use managed identity
    }
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'azure'  // use Azure CNI
      loadBalancerSku: 'standard'
    }
  }
}

output id string = aks.id
output apiServerAddress string = aks.properties.fqdn