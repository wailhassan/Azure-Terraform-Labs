/*
Manages an Azure Public DNS Zone           
By: Wail Hassan                  
https://github.com/wailhassan */

// All resources and services are in the 'services.tf' file
###########################################################

// Create an Azure Public DNS Zone
resource "azurerm_dns_zone" "cloudtestlab_com" {
  name                = "cloudtestlab.com"
  resource_group_name = azurerm_resource_group.app_grp.name
}


// To get the Nameservers
output "server_names" {
  value = azurerm_dns_zone.cloudtestlab_com.name_servers
}


//Enables you to manage DNS A Records within Azure DNS
resource "azurerm_dns_a_record" "load_balancer_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.cloudtestlab_com.name
  resource_group_name = azurerm_resource_group.app_grp.name
  ttl                 = 300
  records             = [azurerm_public_ip.load_ip.ip_address]
}



