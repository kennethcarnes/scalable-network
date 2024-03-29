param location string
param vmSize string = 'Standard_B1s'
param spokeVnetDetails array
param adminUsername string
@secure()
param adminPassword string

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2021-03-01' = [for (vnet, i) in spokeVnetDetails: {
  name: '${vnet.name}-vm-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'Subnet1')
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource spokeVMs 'Microsoft.Compute/virtualMachines@2021-07-01' = [for (vnet, i) in spokeVnetDetails: {
  name: '${vnet.name}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vnet.name}-vm'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
    }
  }
  dependsOn: [
    networkInterfaces
  ]
}]
