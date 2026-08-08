targetScope = 'subscription'

@description('The name of the Resource Group to create.')
param resourceGroupName string

@description('The Azure region where the Resource Group will be created.')
param location string

@description('Tags to apply to the Resource Group.')
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

@description('The ID of the created Resource Group.')
output resourceGroupId string = rg.id

@description('The name of the created Resource Group.')
output resourceGroupName string = rg.name
