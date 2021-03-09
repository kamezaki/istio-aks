// Specifies the Azure location where the key vault should be created.
param location string = resourceGroup().location
// Kubernetes versoin.
param kubernetesVersion string
// The name of the Managed Cluster resource.
param clusterName string = 'sample-istio'
// The DNS prefix to use with hosted Kubernetes API server FQDN.
param dnsPrefix string = '${clusterName}'
// The name of the default agent pool name.
param defaultAgentPoolName  string = 'defaultpool'
// Array for availability zones
param availabilityZones array = []
// The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production
@minValue(1)
@maxValue(50)
param agentMinCount int = 1
// The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production
@minValue(1)
@maxValue(100)
param agentMaxCount int = 1
// The size of the Virtual Machine.
param agentVMSize string = 'Standard_D2_v3'
// The resource group name for aks node.
param nodeResourceGroup string = 'rg-${clusterName}-aks'
// Subnet reference name for aks
param subnetRef string
// Tag information for aks resource
param tags object = {}

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
        count: agentMinCount
        minCount: agentMinCount
        maxCount: agentMaxCount
        mode: 'System'
        vmSize: agentVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: true
        availabilityZones: length(availabilityZones) == 0 ? json('null') : availabilityZones
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