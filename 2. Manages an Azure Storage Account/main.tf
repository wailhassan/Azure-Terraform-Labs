/*
Manages an Azure Storage Account           
By: Wail Hassan                  
https://github.com/wailhassan
*/


// Variables For storage account
variable "storage_account_name" {
  type        = string
  description = "Please Add you storage account Name"
}

// Create a Storage Account 
resource "azurerm_storage_account" "Storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  // Dependencies between resources
  depends_on = [azurerm_resource_group.app_grp]
}
