// Network and subnets
resource "azurerm_virtual_network" "lettyVNET" {
  name                = "Letty-Net"
  address_space       = [var.vnetcidr]
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name
}

resource "azurerm_subnet" "frontendSubnet" {
  name                 = "frontendSubnet"
  resource_group_name  = azurerm_resource_group.lettyRG.name
  virtual_network_name = azurerm_virtual_network.lettyVNET.name
  address_prefixes     = [var.webcidr]
}

resource "azurerm_subnet" "backendSubnet" {
  name                 = "backendSubnet"
  resource_group_name  = azurerm_resource_group.lettyRG.name
  virtual_network_name = azurerm_virtual_network.lettyVNET.name
  address_prefixes     = [var.dbcidr]
}

// Network Interface Cards NIC
resource "azurerm_network_interface" "webserverNIC" {
  name                = "web-server-nic"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.frontendSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.10.10"
  }
}

resource "azurerm_network_interface" "dbserverNIC" {
  name                = "db-server-nic"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backendSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.20.20"
  }
}

// Nat Gateway
resource "azurerm_public_ip" "natGwPIP" {
  name                = "nat-gw-publicip"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "natGwIPPrefix" {
  name                = "nat-gateway-publicIPPrefix"
  location            = azurerm_resource_group.lettyRG.location
  resource_group_name = azurerm_resource_group.lettyRG.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "natGW" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.lettyRG.location
  resource_group_name     = azurerm_resource_group.lettyRG.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

// Associate Nat Gateway to public ip and subnet
resource "azurerm_nat_gateway_public_ip_association" "natGwAssocPIP" {
  nat_gateway_id       = azurerm_nat_gateway.natGW.id
  public_ip_address_id = azurerm_public_ip.natGwPIP.id
}

resource "azurerm_subnet_nat_gateway_association" "natGwAssocFrontSubnet" {
  subnet_id      = azurerm_subnet.frontendSubnet.id
  nat_gateway_id = azurerm_nat_gateway.natGW.id
}

resource "azurerm_subnet_nat_gateway_association" "natGwAssocBackSubnet" {
  subnet_id      = azurerm_subnet.backendSubnet.id
  nat_gateway_id = azurerm_nat_gateway.natGW.id
}

