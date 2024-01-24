
locals {
  resource_group = "app-grp"
  location       = "North Europe"
}


resource "azurerm_resource_group" "app_grp" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_resource_group" "app_grp2" {
  name     = "app-grp2"
  location = "UK South"
}
