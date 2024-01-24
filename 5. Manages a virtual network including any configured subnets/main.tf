/*
Manages a virtual network including any configured subnets          
By: Wail Hassan                  
https://github.com/wailhassan
*/

// Create New Virual Networks
resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]

}

// Create a subnet
resource "azurerm_subnet" "SubnetA" {
  name                 = "SubmetA"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.app_network]
}