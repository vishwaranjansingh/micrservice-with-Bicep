@description('The name of the Log Analytics workspace.')
param workspaceName string

@description('The Azure region for the Log Analytics workspace.')
param location string

@description('Retention period in days.')
param retentionInDays int = 30

@description('Tags to apply to the Log Analytics workspace.')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

@description('The resource ID of the Log Analytics Workspace.')
output workspaceId string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics Workspace.')
output workspaceName string = logAnalyticsWorkspace.name
