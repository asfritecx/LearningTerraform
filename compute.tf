resource "azurerm_windows_virtual_machine" "LAPP01" {
  name                = "LAPP01"
  resource_group_name = azurerm_resource_group.lettyRG.name
  location            = azurerm_resource_group.lettyRG.location
  size                = "Standard_B2s"
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
  size                = "Standard_B2s"
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