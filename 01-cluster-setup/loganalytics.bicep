@description('Prefix string for Log analytics workspace name')
@minLength(2)
@maxLength(16)
param workspaceNamePrefix string
param location string = resourceGroup().location
param sku string = 'pergb2018'
@minValue(30)
@maxValue(730)
param retentionDays int = 90

var subscriptionId = subscription().subscriptionId
var workspaceName = '${workspaceNamePrefix}-${subscriptionId}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01'= {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionDays
  }
}

output workspaceId string = workspace.id
