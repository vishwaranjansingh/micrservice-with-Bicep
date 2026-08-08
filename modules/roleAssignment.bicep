@description('The name of the Azure Container Registry.')
param acrName string

@description('The Principal ID of the AKS Kubelet Identity.')
param principalId string

// AcrPull role definition ID in Azure RBAC
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, principalId, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

@description('The ID of the AcrPull Role Assignment.')
output roleAssignmentId string = roleAssignment.id
