/*
Manages an Azure SQL Database
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



