/*
Manages a virtual machine scale set         
By: Wail Hassan                  
https://github.com/wailhassan */

// Create a Virtual Network
resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

// Create a Subnet
resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

// Create a Public IP
resource "azurerm_public_ip" "load_ip" {
  name                = "load-ip"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


// Create a Load Balancer
resource "azurerm_lb" "app_balancer" {
  name                = "app-balancer"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }
  sku        = "Standard"
  depends_on = [azurerm_public_ip.load_ip]
}


// Backend Address Pool
resource "azurerm_lb_backend_address_pool" "scalesetpool" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "scalesetpool"
  depends_on      = [azurerm_lb.app_balancer]
}

// Create a LoadBalancer Probe Resource
resource "azurerm_lb_probe" "ProbeA" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "ProbeA"
  port            = 80
  protocol        = "Tcp"
  depends_on      = [azurerm_lb.app_balancer]
}


// Create a Load Balancer Rule
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.scalesetpool.id]
  probe_id                       = azurerm_lb_probe.ProbeA.id
  depends_on = [azurerm_lb.app_balancer,
  azurerm_lb_probe.ProbeA]
}

// Create a Windows Virtual Machine Scale Set
resource "azurerm_windows_virtual_machine_scale_set" "scale_set" {
  name                 = "scale-set"
  resource_group_name  = azurerm_resource_group.app_grp.name
  location             = azurerm_resource_group.app_grp.location
  sku                  = "Standard_D2s_v3"
  instances            = 3
  admin_password       = "Azure@123"
  admin_username       = "vmuser"
  computer_name_prefix = "vm-scale"
  upgrade_mode         = "Automatic"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "scaleset-interface"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.SubnetA.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.scalesetpool.id]
    }
  }
  depends_on = [azurerm_virtual_network.app_network]
}

// Create a Storage Account 
resource "azurerm_storage_account" "appstore" {
  name                     = "appstoragee2030"
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  //allow_blob_public_access = true
}

resource "azurerm_storage_container" "data_cont" {
  name                  = "data-cont"
  storage_account_name  = "appstoragee2030"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.appstore
  ]
}

// uploading the IIS Configuration script as a blob to the storage account

resource "azurerm_storage_blob" "IIS_config" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = "appstoragee2030"
  storage_container_name = "data-cont"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
  depends_on             = [azurerm_storage_container.data_cont]
}


// applying the custom script extension on the 
// virtual machine scale set
resource "azurerm_virtual_machine_scale_set_extension" "scaleset_extension" {
  name                         = "scaleset-extension"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.scale_set.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.9"
  depends_on = [
    azurerm_storage_blob.IIS_config
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data-cont/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS
}


// Create a Network Security Group
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  // Create a rule to allow traffic on port 80
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





