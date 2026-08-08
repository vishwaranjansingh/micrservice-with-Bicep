@description('The Azure region for the network resources.')
param location string

@description('The name of the Virtual Network.')
param vnetName string

@description('The name of the Network Security Group.')
param nsgName string

@description('Address space prefixes for the Virtual Network.')
param vnetAddressPrefixes array = [
  '10.240.0.0/16'
]

@description('Subnet name for the AKS cluster.')
param aksSubnetName string = 'aks-subnet'

@description('Address prefix for the AKS subnet.')
param aksSubnetPrefix string = '10.240.0.0/20'

@description('Tags to apply to network resources.')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allow-kube-apiserver'
        properties: {
          description: 'Allow HTTPS traffic for API server communication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

@description('The ID of the created Virtual Network.')
output vnetId string = vnet.id

@description('The name of the created Virtual Network.')
output vnetName string = vnet.name

@description('The ID of the AKS subnet.')
output aksSubnetId string = vnet.properties.subnets[0].id

@description('The name of the AKS subnet.')
output aksSubnetName string = vnet.properties.subnets[0].name
