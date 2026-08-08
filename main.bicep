targetScope = 'subscription'

@description('Primary Azure region for all resources.')
param location string = 'koreacentral'

@description('Environment name (e.g. dev, test, prod).')
param environment string = 'dev'

@description('Project or application prefix for resource naming.')
param projectPrefix string = 'microservices'

@description('Name of the Resource Group to create.')
param resourceGroupName string = 'rg-${projectPrefix}-${environment}'

@description('Globally unique ACR name (letters and numbers only).')
param acrName string = 'acr${projectPrefix}${environment}'

@description('SKU for the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

@description('Name of the AKS cluster.')
param aksClusterName string = 'aks-${projectPrefix}-${environment}'

@description('DNS prefix for the AKS cluster control plane.')
param dnsPrefix string = 'aks-${projectPrefix}-${environment}-dns'

@description('Kubernetes version for the AKS cluster. Leave empty to use the default supported version for the region.')
param kubernetesVersion string = ''

@description('VM size for the system node pool (Standard_B2s is allowed in Free Subscription).')
param systemVmSize string = 'Standard_B2s'

@description('Minimum node count for the system node pool.')
param minNodeCount int = 1

@description('Maximum node count for the system node pool.')
param maxNodeCount int = 3

@description('Common tags for resources.')
param tags object = {
  Environment: environment
  Project: projectPrefix
  ManagedBy: 'Bicep'
}

// 1. Resource Group Module
module resourceGroup 'modules/resourceGroup.bicep' = {
  name: 'deploy-rg'
  params: {
    resourceGroupName: resourceGroupName
    location: location
    tags: tags
  }
}

// 2. Log Analytics Workspace Module
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'deploy-log-analytics'
  scope: az.resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup
  ]
  params: {
    workspaceName: 'log-${projectPrefix}-${environment}'
    location: location
    tags: tags
  }
}

// 3. Virtual Network Module
module network 'modules/network.bicep' = {
  name: 'deploy-network'
  scope: az.resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup
  ]
  params: {
    vnetName: 'vnet-${projectPrefix}-${environment}'
    nsgName: 'nsg-${projectPrefix}-${environment}'
    location: location
    tags: tags
  }
}

// 4. User-Assigned Managed Identity Module
module identity 'modules/identity.bicep' = {
  name: 'deploy-identity'
  scope: az.resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup
  ]
  params: {
    identityName: 'id-aks-${projectPrefix}-${environment}'
    location: location
    tags: tags
  }
}

// 5. Azure Container Registry Module
module acr 'modules/acr.bicep' = {
  name: 'deploy-acr'
  scope: az.resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup
  ]
  params: {
    acrName: acrName
    acrSku: acrSku
    location: location
    tags: tags
  }
}

// 6. Azure Kubernetes Service Module
module aks 'modules/aks.bicep' = {
  name: 'deploy-aks'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    aksClusterName: aksClusterName
    location: location
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    userAssignedIdentityId: identity.outputs.identityId
    vnetSubnetId: network.outputs.aksSubnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    vmSize: systemVmSize
    minNodeCount: minNodeCount
    maxNodeCount: maxNodeCount
    tags: tags
  }
}

// 7. ACR Pull Role Assignment Module for AKS Kubelet Identity
module roleAssignment 'modules/roleAssignment.bicep' = {
  name: 'deploy-role-assignment'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    acrName: acr.outputs.acrName
    principalId: aks.outputs.kubeletIdentityObjectId
  }
}

@description('Resource Group Name')
output resourceGroupName string = resourceGroup.outputs.resourceGroupName

@description('Azure Container Registry Name')
output acrName string = acr.outputs.acrName

@description('Azure Container Registry Login Server')
output acrLoginServer string = acr.outputs.loginServer

@description('AKS Cluster Name')
output aksClusterName string = aks.outputs.aksClusterName

@description('AKS API Server FQDN')
output aksControlPlaneFQDN string = aks.outputs.controlPlaneFQDN

@description('AKS OIDC Issuer URL')
output aksOidcIssuerUrl string = aks.outputs.oidcIssuerUrl
