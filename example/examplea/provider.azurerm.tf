provider "azurerm" {
  features {}
  # shared key access is disabled on the storage account, so use Entra ID for storage data plane calls
  storage_use_azuread = true
}
