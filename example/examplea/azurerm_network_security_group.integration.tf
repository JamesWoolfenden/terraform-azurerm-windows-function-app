resource "azurerm_network_security_group" "integration" {
  name                = "pike-win-function-integration"
  location            = azurerm_resource_group.function.location
  resource_group_name = azurerm_resource_group.function.name
  tags                = var.common_tags
}
