resource "azurerm_resource_group" "lettyRG" {
  name     = "lettyRG"
  location = "eastus"
}

resource "azurerm_virtual_network" "lettyVNET" {
  name                = "Letty-Net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name
}

resource "azurerm_subnet" "frontendSubnet" {
  name                 = "frontendSubnet"
  resource_group_name  = azurerm_resource_group.lettyRG.name
  virtual_network_name = azurerm_virtual_network.lettyVNET.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "backendSubnet" {
  name                 = "backendSubnet"
  resource_group_name  = azurerm_resource_group.lettyRG.name
  virtual_network_name = azurerm_virtual_network.lettyVNET.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_network_interface" "webserverNIC" {
  name                = "webserverNIC"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.frontendSubnet.id
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.10.10"
  }
}

resource "azurerm_network_interface" "dbserverNIC" {
  name                = "dbserverNIC"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backendSubnet.id
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.20.20"
  }
}

resource "azurerm_windows_virtual_machine" "LAPP01" {
  name                = "LAPP01"
  resource_group_name = azurerm_resource_group.lettyRG.name
  location            = azurerm_resource_group.lettyRG.location
  size                = "Standard_B2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.webserverNIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-Azure-Edition"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "LDB01" {
  name                = "LDB01"
  resource_group_name = azurerm_resource_group.lettyRG.name
  location            = azurerm_resource_group.lettyRG.location
  size                = "Standard_B2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.dbserverNIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-Azure-Edition"
    version   = "latest"
  }
}