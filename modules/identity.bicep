@description('The Azure region for the managed identity.')
param location string

@description('The name of the user-assigned managed identity.')
param identityName string

@description('Tags to apply to the managed identity resource.')
param tags object = {}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

@description('The resource ID of the User-Assigned Managed Identity.')
output identityId string = userAssignedIdentity.id

@description('The Principal ID of the User-Assigned Managed Identity.')
output principalId string = userAssignedIdentity.properties.principalId

@description('The Client ID of the User-Assigned Managed Identity.')
output clientId string = userAssignedIdentity.properties.clientId
