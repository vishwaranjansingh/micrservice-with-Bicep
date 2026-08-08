@description('The name of the Azure Kubernetes Service cluster.')
param aksClusterName string

@description('The Azure region for the AKS cluster.')
param location string

@description('DNS prefix for the AKS cluster control plane.')
param dnsPrefix string

@description('Resource ID of the User-Assigned Managed Identity for the control plane.')
param userAssignedIdentityId string

@description('Resource ID of the Subnet where AKS nodes will be deployed.')
param vnetSubnetId string

@description('Resource ID of the Log Analytics Workspace for Container Insights.')
param logAnalyticsWorkspaceId string

@description('Kubernetes version for the AKS cluster. Leave empty to use the region default.')
param kubernetesVersion string = ''

@description('VM SKU size for the system node pool (Standard_B2s is cost-effective for Free Trial).')
param vmSize string = 'Standard_B2s'

@description('Minimum number of nodes for the system node pool.')
param minNodeCount int = 1

@description('Maximum number of nodes for the system node pool.')
param maxNodeCount int = 3

@description('Tags to apply to the AKS cluster.')
param tags object = {}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    kubernetesVersion: !empty(kubernetesVersion) ? kubernetesVersion : null
    dnsPrefix: dnsPrefix
    enableRBAC: true
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'azure'
      dnsServiceIP: '192.168.0.10'
      serviceCidr: '192.168.0.0/16'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: minNodeCount
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: vnetSubnetId
        enableAutoScaling: true
        minCount: minNodeCount
        maxCount: maxNodeCount
        type: 'VirtualMachineScaleSets'
        osDiskSizeGB: 64
        osDiskType: 'Managed'
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}

@description('The resource ID of the created AKS cluster.')
output aksClusterId string = aksCluster.id

@description('The name of the created AKS cluster.')
output aksClusterName string = aksCluster.name

@description('The Principal ID of the AKS kubelet identity.')
output kubeletIdentityObjectId string = aksCluster.properties.identityProfile.kubeletidentity.objectId

@description('The OIDC Issuer URL for workload identity configuration.')
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL

@description('The FQDN of the AKS API server.')
output controlPlaneFQDN string = aksCluster.properties.fqdn
