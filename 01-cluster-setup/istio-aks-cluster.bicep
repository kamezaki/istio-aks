// originally from: https://github.com/Azure/bicep/blob/fef0778170033b005b188ac140c04586ff39f4a0/docs/examples/101/aks-vmss-systemassigned-identity/main.bicep
//
// Before you will specify the parameters, you can see the naming rules for AKS at  https://aka.ms/aks-naming-rules
//

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Specifies the Azure location where the key vault should be created.'
  }
}
param dnsPrefix string {
  default: 'istio-aks'
  metadata: {
    description: 'The DNS prefix to use with hosted Kubernetes API server FQDN.'
  }
}
param clusterName string {
  default: 'sample-with-istio'
  metadata: {
    description: 'The name of the Managed Cluster resource.'
  }
}
param defaultAgentPoolName  string {
  default: 'defaultpool'
  metadata: {
    description: 'The name of the default agent pool name.'
  }
}
param agentMinCount int {
  default: 1
  minValue: 1
  maxValue: 50
  metadata: {
    description: 'The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production'
  }
}
param agentMaxCount int {
  default: 1
  minValue: 1
  maxValue: 100
  metadata: {
    description: 'The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production'
  }
}
param agentVMSize string {
  default: 'Standard_D2_v3'
  metadata: {
    description: 'The size of the Virtual Machine.'
  }
}
param nodeResourceGroup string {
  default: 'rg-${clusterName}-aks'
  metadata: {
    description: 'The resource group name for aks node.'
  }
}
param kubernetesVersion string {
  metadata: {
    description: 'Kubernetes versoin.'    
  }
}
param tags object {
  default: {}
  metadata: {
    description: 'Tag information for aks resource'
  }
}

// virtual network configurations
var virtualNetworkName = 'vnet-${clusterName}-${location}'
var addressPrefix =  '172.27.0.0/16'
var subnetName = 'subnet-${clusterName}-k8s-${location}'
var subnetPrefix = '172.27.0.0/24'
var subnetRef = '${vn.id}/subnets/${subnetName}'

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
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: defaultAgentPoolName
        minCount: agentMinCount
        maxCount: agentMaxCount
        mode: 'System'
        vmSize: agentVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: true
        vnetSubnetID: subnetRef
      }
    ]
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