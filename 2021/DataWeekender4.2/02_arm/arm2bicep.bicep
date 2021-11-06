@description('nicName')
param nicName string = 'bicepnic'

@description('Username for the Virtual Machine.')
param adminUsername string = 'mikey'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string = '!0AzureAdmin'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'biceppublicip'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2008-R2-SP1'
  '2012-Datacenter'
  '2012-R2-Datacenter'
  '2016-Nano-Server'
  '2016-Datacenter-with-Containers'
  '2016-Datacenter'
  '2019-Datacenter'
  '2019-Datacenter-Core'
  '2019-Datacenter-Core-smalldisk'
  '2019-Datacenter-Core-with-Containers'
  '2019-Datacenter-Core-with-Containers-smalldisk'
  '2019-Datacenter-smalldisk'
  '2019-Datacenter-with-Containers'
  '2019-Datacenter-with-Containers-smalldisk'
])
param OSVersion string = '2019-Datacenter'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2_v3'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string = 'bicepvm'

var storageAccountName_var_var = 'bootdiags${uniqueString(resourceGroup().id)}'
var nicName_var_var = nicName
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName_var_var = 'bicepvnet'
var networkSecurityGroupName_var_var = 'default-NSG'

resource storageAccountName_var 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName_var_var
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource publicIpName_resource 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroupName_var 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: networkSecurityGroupName_var_var
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetworkName_var 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName_var_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupName_var.id
          }
        }
      }
    ]
  }
}

resource nicName_var 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName_var_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bicepipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpName_resource.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_var_var, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName_var
  ]
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicName_var.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccountName_var.properties.primaryEndpoints.blob
      }
    }
  }
}

resource vmName_dscextension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: vmName_resource
  name: 'dscextension'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    forceUpdateTag: '3'
    settings: {
      configuration: {
        url: 'https://mikeybronowski5.blob.core.windows.net/dscconfig/config.ps1.zip'
        script: 'config.ps1'
        function: 'SqlInstall'
      }
    }
  }
}

output hostname string = publicIpName_resource.properties.dnsSettings.fqdn