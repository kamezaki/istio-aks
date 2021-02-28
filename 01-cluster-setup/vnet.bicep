
param location string {
  default: resourceGroup().location
  metadata: {
    description: 'Specifies the Azure location where the key vault should be created.'
  }
}
param tags object {
  default: {}
  metadata: {
    description: 'Tag information for vnet'
  }
}
param virtualNetworkName string {
  metadata: {
    description: 'Virtual network name'
  }
}
param addressPrefix string {
  default: '172.27.0.0/16'
  metadata: {
    description: 'Address prefix for virtual network'
  }
}
param subnetPrefix string {
  default: '172.27.0.0/24'
  metadata: {
    description: 'Subnet prefix for virtual network'
  }
}
param subnetName string {
  metadata: {
    description: 'Subnet name'
  }

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

output id string = vn.id
