
// Specifies the Azure location where the key vault should be created.
param location string =resourceGroup().location
// Tag information for vnet
param tags object = {}
// Virtual network name
param virtualNetworkName string
// Address prefix for virtual network
param addressPrefix string = '172.27.0.0/16'
// Subnet prefix for virtual network
param subnetPrefix string = '172.27.0.0/24'
// Subnet name
param subnetName string

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

output id string = vn.id
