/*
Manages an Application Gateway  
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

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = local.resource_group
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}


// Create a subnet for the Azure Application Gateway resource

resource "azurerm_subnet" "SubnetB" {
  name                 = "SubnetB"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

// Create an interface for appvm1

resource "azurerm_network_interface" "app_interface1" {
  name                = "app-interface1"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.SubnetA
  ]
}

// Craete an interface for appvm2

resource "azurerm_network_interface" "app_interface2" {
  name                = "app-interface2"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.SubnetA
  ]
}

// Create the resource for appvm1

resource "azurerm_windows_virtual_machine" "app_vm1" {
  name                = "appvm1"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "demousr"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.app_interface1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface1
  ]
}

// Create the resource for appvm2

resource "azurerm_windows_virtual_machine" "app_vm2" {
  name                = "appvm2"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "demousr"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.app_interface2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface2
  ]
}

// Create a Storage Account for the HTML Files

resource "azurerm_storage_account" "appstore" {
  name                     = "appssttoreettest45"
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "appssttoreettest45"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.appstore
  ]
}


resource "azurerm_storage_blob" "IIS_config_video" {
  name                   = "IIS_Config_video.ps1"
  storage_account_name   = "appssttoreettest45"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config_video.ps1"
  depends_on             = [azurerm_storage_container.data]
}

resource "azurerm_storage_blob" "IIS_config_image" {
  name                   = "IIS_Config_image.ps1"
  storage_account_name   = "appssttoreettest45"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config_image.ps1"
  depends_on             = [azurerm_storage_container.data]
}

// Create an extension for appvm1

resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_video
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config_video.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_video.ps1"     
    }
SETTINGS
}


// Craete an extension for appvm2

resource "azurerm_virtual_machine_extension" "vm_extension2" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config_image
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config_image.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_image.ps1"     
    }
SETTINGS
}


// Create NSG (Network Security Group)

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  # Create a rule to allow traffic on port 80
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}

// Create a public IP address that's needed for the Azure Application Gateway

resource "azurerm_public_ip" "gateway_ip" {
  name                = "gateway-ip"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  allocation_method   = "Dynamic"

}


//Define an Azure Application Gateway resource

resource "azurerm_application_gateway" "app_gateway" {
  name                = "app-gateway"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location

   sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }


  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.SubnetB.id
  }

  frontend_port {
    name = "front-end-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "front-end-ip-config"
    public_ip_address_id = azurerm_public_ip.gateway_ip.id
  }


  // Eensure that the virtual machines are added to the backend pool
  // of the Azure Application Gateway

  backend_address_pool {
    name = "videopool"
    ip_addresses = [
      "${azurerm_network_interface.app_interface1.private_ip_address}"
    ]
  }

  backend_address_pool {
    name = "imagepool"
    ip_addresses = [
    "${azurerm_network_interface.app_interface2.private_ip_address}"]

  }


  backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }


  http_listener {
    name                           = "gateway-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "front-end-port"
    protocol                       = "Http"
  }

  // Implementing the URL routing rules
  request_routing_rule {
    name               = "RoutingRuleA"
   priority           = 9
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RoutingPath"
    http_listener_name = "gateway-listener"
  }

  url_path_map {
    name                               = "RoutingPath"
    default_backend_address_pool_name  = "videopool"
    default_backend_http_settings_name = "HTTPSetting"

    path_rule {
      name                       = "VideoRoutingRule"
      backend_address_pool_name  = "videopool"
      backend_http_settings_name = "HTTPSetting"
      paths = [
        "/videos/*",
      ]
    }

    path_rule {
      name                       = "ImageRoutingRule"
      backend_address_pool_name  = "imagepool"
      backend_http_settings_name = "HTTPSetting"
      paths = [
        "/images/*",
      ]
    }
  }
}

