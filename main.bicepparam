using 'main.bicep'

param location = 'koreacentral'
param environment = 'dev'
param projectPrefix = 'microservice'
param resourceGroupName = 'rg-microservice-dev'
param acrName = 'acrmicroservicedev2026'
param acrSku = 'Basic'
param aksClusterName = 'aks-microservice-dev'
param dnsPrefix = 'aks-microservice-dev-dns'
param kubernetesVersion = ''
param systemVmSize = 'Standard_B2s'
param minNodeCount = 1
param maxNodeCount = 3

param tags = {
  Environment: 'dev'
  Project: 'microservice-landing-zone'
  ManagedBy: 'Bicep'
  Owner: 'DevOps'
}
