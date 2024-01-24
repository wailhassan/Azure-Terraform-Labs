/*
Manages an App Service (within an App Service Plan)
By: Wail Hassan                  
https://github.com/wailhassan
*/


# Create a new app service plan:
resource "azurerm_app_service_plan" "app_plan1000" {
  name                = "app-plan1000"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  sku {
    tier = "Free"
    size = "F1"
  }

}

# Create an App Service
resource "azurerm_app_service" "tt2ss2appweb1" {
  name                = "tt2ss2-appweb1"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.app_plan1000.id
}


