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
    private_ip_address_allocation = "Static"
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
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.20.20"
  }
}