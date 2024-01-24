/*
Manages a Function App    
By: Wail Hassan                  
https://github.com/wailhassan */



locals {
  resource_group = "app-grp"
  location       = "North Europe"
}


resource "azurerm_resource_group" "app_grp" {
  name     = local.resource_group
  location = local.location
}



// Create a Storage account 

resource "azurerm_storage_account" "functionstore_089889" {
  name                     = "functiionstoreettt21"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Create an App Service Plan

resource "azurerm_app_service_plan" "function_app_plan" {
  name                = "function-app-plan"
  location            = local.location
  resource_group_name = local.resource_group

  sku {
    tier = "Standard"
    size = "S1"
  }
}

// Create a Function App

resource "azurerm_function_app" "functionapp_1234000" {
  name                       = "functionapp-1234000"
  location                   = local.location
  resource_group_name        = local.resource_group
  app_service_plan_id        = azurerm_app_service_plan.function_app_plan.id
  storage_account_name       = azurerm_storage_account.functionstore_089889.name
  storage_account_access_key = azurerm_storage_account.functionstore_089889.primary_access_key

  site_config {
    dotnet_framework_version = "v6.0"
  }
}