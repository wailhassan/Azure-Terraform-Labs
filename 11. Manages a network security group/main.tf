/*
Manages a network security group    
By: Wail Hassan                  
https://github.com/wailhassan
*/

# Create New Virual Networks
resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]

}

# Create a subnet
resource "azurerm_subnet" "SubnetA" {
  name                 = "SubmetA"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.app_network]
}

//////////////////////////////////////////////////////////////

# Create a Network Interface
resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_public_ip.app_public_ip,
    azurerm_subnet.SubnetA
  ]
}


# Create a Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "demousr"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
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
    azurerm_network_interface.app_interface,
    azurerm_availability_set.app_set
  ]
}

# Create a managed disk:
resource "azurerm_managed_disk" "data_disk" {
  name                 = "data-disk"
  location             = local.location
  resource_group_name  = local.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16
}
# Attaching a Disk to a Virtual Machine
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on = [
    azurerm_windows_virtual_machine.app_vm,
    azurerm_managed_disk.data_disk
  ]
}

# Create a Public IP Address 
resource "azurerm_public_ip" "app_public_ip" {
  name                = "app-public-ip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

# Create an Availability Set
resource "azurerm_availability_set" "app_set" {
  name                         = "app-set"
  location                     = local.location
  resource_group_name          = local.resource_group
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}


####################################################


# Create a Storage Account 
resource "azurerm_storage_account" "appstore" {
  name                     = "stoargeeacc40ee1"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Storage Container
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "stoargeeacc40ee1"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.appstore
  ]
}

# uploading the IIS Configuration script as a blob
# to the Azure storage account

resource "azurerm_storage_blob" "IIS_Config" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = "stoargeeacc40ee1"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
  depends_on             = [azurerm_storage_container.data]
}

resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_Config
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS

}

#------------------------------------------------------#

# Create a Network Security Group
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = local.location
  resource_group_name = local.resource_group

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



