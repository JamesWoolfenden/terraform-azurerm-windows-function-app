resource "azurerm_resource_group" "function" {
  name     = "pike-win-function"
  location = "uk south"
  tags     = var.common_tags
}
