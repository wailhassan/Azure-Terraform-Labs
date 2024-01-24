/*
Manages an App Service Connecting to Database
By: Wail Hassan                  
https://github.com/wailhassan
*/


# Create a new SQL Server
resource "azurerm_sql_server" "app_server" {
  name                         = "appserver6008089"
  resource_group_name          = azurerm_resource_group.app_grp.name
  location                     = azurerm_resource_group.app_grp.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Azure@123"

}

# Create a new SQL Database
resource "azurerm_sql_database" "appdb" {
  name                = "appdb"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  server_name         = azurerm_sql_server.app_server.name

  depends_on = [azurerm_sql_server.app_server]

}

# Create a new SQL Firewall Rule
resource "azurerm_sql_firewall_rule" "appserfirewall" {
  name                = "appserfirewall"
  resource_group_name = azurerm_resource_group.app_grp.name
  server_name         = azurerm_sql_server.app_server.name
  //What is my IP:
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"

  depends_on = [azurerm_sql_server.app_server]
}


###############################################

# Create an App Service Paln
resource "azurerm_app_service_plan" "app_plan1000" {
  name                = "app-plan1000"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Craete an App Service
resource "azurerm_app_service" "webapptest1" {
  name                = "webapp2test1"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.app_plan1000.id
  source_control {
    # You can find the project file from author Github link:
    # https://github.com/wailhassan
    repo_url           = "https://github.com/wailhassan/ProductApp.git"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
  depends_on = [azurerm_app_service_plan.app_plan1000]
}

# Create a new SQL Firewall Rule
resource "azurerm_sql_firewall_rule" "app_server_firewall_rule_Azure_services" {
  name                = "app-server-firewall-rule-Allow-Azure-services"
  resource_group_name = azurerm_resource_group.app_grp.name
  server_name         = azurerm_sql_server.app_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on = [
    azurerm_sql_server.app_server
  ]
}

