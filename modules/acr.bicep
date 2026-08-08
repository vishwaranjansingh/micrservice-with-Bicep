@description('The name of the Azure Container Registry. Must be globally unique and alphanumeric.')
param acrName string

@description('The Azure region for the ACR.')
param location string

@description('The SKU of the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Standard'

@description('Enable or disable admin user on the ACR. Recommended to disable for security best practices.')
param adminUserEnabled bool = false

@description('Tags to apply to the ACR resource.')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  tags: tags
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: acrSku == 'Premium' ? 'Enabled' : 'Disabled'
  }
}

@description('The resource ID of the Azure Container Registry.')
output acrId string = acr.id

@description('The name of the Azure Container Registry.')
output acrName string = acr.name

@description('The login server URL of the Azure Container Registry.')
output loginServer string = acr.properties.loginServer
