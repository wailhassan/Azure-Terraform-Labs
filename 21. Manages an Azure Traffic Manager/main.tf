/*
Manages an Azure Traffic Manager        
By: Wail Hassan                  
https://github.com/wailhassan */


resource "azurerm_app_service_plan" "primary_plan" {
  name                = "primary-plan2024"
  location            = local.location
  resource_group_name = local.resource_group

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "primary_webapp" {
  name                = "primaryapp2024"
  location            = local.location
  resource_group_name = local.resource_group
  app_service_plan_id = azurerm_app_service_plan.primary_plan.id
  site_config {
    dotnet_framework_version = "v6.0"
  }
  source_control {
    repo_url           = "https://github.com/wailhassan/PrimaryApp.git"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

resource "azurerm_app_service_plan" "secondary_plan" {
  name                = "secondary-plan2024"
  location            = azurerm_resource_group.app_grp2.location
  resource_group_name = azurerm_resource_group.app_grp2.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "secondary_webapp" {
  name                = "secondaryapp2024"
  location            = azurerm_resource_group.app_grp2.location
  resource_group_name = azurerm_resource_group.app_grp2.name
  app_service_plan_id = azurerm_app_service_plan.secondary_plan.id
  site_config {
    dotnet_framework_version = "v6.0"
  }
  source_control {
    repo_url           = "https://github.com/wailhassan/SecondaryApp.git"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

// Create a Traffic Manager Profile

resource "azurerm_traffic_manager_profile" "traffic_profile" {
  name                   = "traffic-profile2024"
  resource_group_name    = local.resource_group
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "traffic-profile2024"
    ttl           = 100
  }
  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 2
  }
}


resource "azurerm_traffic_manager_azure_endpoint" "primary_endpoint" {
  name               = "primary-endpoint2024"
  profile_id         = azurerm_traffic_manager_profile.traffic_profile.id
  priority           = 1
  weight             = 100
  target_resource_id = azurerm_app_service.primary_webapp.id
}


resource "azurerm_traffic_manager_azure_endpoint" "secondary_endpoint" {
  name                           = "secondary-end241"
  profile_id                          = azurerm_traffic_manager_profile.traffic_profile.id
  priority                       = 2
  weight                     = 100
  target_resource_id         = azurerm_app_service.secondary_webapp.id
}