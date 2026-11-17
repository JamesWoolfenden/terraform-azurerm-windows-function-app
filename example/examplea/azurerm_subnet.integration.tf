resource "azurerm_subnet" "integration" {
  name                 = "integration"
  resource_group_name  = azurerm_resource_group.function.name
  virtual_network_name = azurerm_virtual_network.function.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "serverfarms"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
