// originally from: https://github.com/Azure/bicep/blob/fef0778170033b005b188ac140c04586ff39f4a0/docs/examples/101/aks-vmss-systemassigned-identity/main.bicep
//
// Before you will specify the parameters, you can see the naming rules for AKS at  https://aka.ms/aks-naming-rules
//

// Common attributs
var location = resourceGroup().location
var tags = {
  environment: 'examples'
}
var serviceName = 'istio-aks'

// vitual network attributes
var vnetName = 'vnet-${serviceName}-${location}'
var subnetName = 'subnet-${serviceName}-aks-${location}'

// kubernetes attributes
var clusterName = '${serviceName}-${location}'
var agentMinCount = 3
var agentMaxCount = 5
var subnetRef = '${vnet.outputs.id}/subnets/${subnetName}'

module vnet './vnet.bicep' = {
  name: '${vnetName}'
  params: {
    virtualNetworkName: '${vnetName}'
    subnetName: '${subnetName}'
    tags: tags
  }
}

module aks './aks-cluster.bicep' = {
  name: '${clusterName}'
  params: {
    clusterName: '${clusterName}'
    kubernetesVersion: '1.19.6'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    agentMinCount: agentMinCount
    agentMaxCount: agentMaxCount
    subnetRef: subnetRef
    tags: tags
  }
}