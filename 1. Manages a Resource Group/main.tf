/*
Manages a Resource Group         
By: Wail Hassan                  
https://github.com/wailhassan */


// Azure provider Code
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

provider "azurerm" {
  // Configuration options
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {}
}


// Variables Local for Resourse Group
locals {
  resource_group_name = "app_grp"
  location            = "North Europe"
}


# Create a Resource Group 
resource "azurerm_resource_group" "app_grp" {
  name     = local.resource_group_name
  location = local.location
}