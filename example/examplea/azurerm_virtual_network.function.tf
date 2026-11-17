resource "azurerm_virtual_network" "function" {
  name                = "pike-win-function"
  location            = azurerm_resource_group.function.location
  resource_group_name = azurerm_resource_group.function.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.common_tags
}
