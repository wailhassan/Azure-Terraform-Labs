/*
Manages a Blob within a Storage Container          
By: Wail Hassan                  
https://github.com/wailhassan
*/

// Create a Storage Account 
resource "azurerm_storage_account" "Storage_account" {
  name                     = "storageeacco29e"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  // Dependencies between resources
  depends_on = [azurerm_resource_group.app_grp]
}

// Create a Container within an Azure Storage Account: 
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "storageeacco29e"
  container_access_type = "blob"
  // Dependencies between resources:
  depends_on = [azurerm_storage_account.Storage_account]
}

// Create a Blob within a Storage Container.
resource "azurerm_storage_blob" "sample" {
  name                   = "sample.txt"
  storage_account_name   = "storageeacco29e"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "sample.txt"
  //Dependencies between resources:
  depends_on = [azurerm_storage_container.data]
}