resource "azurerm_storage_account" "function" {
  name                              = "pikewinfunction"
  resource_group_name               = azurerm_resource_group.function.name
  location                          = azurerm_resource_group.function.location
  account_tier                      = "Standard"
  account_replication_type          = "GRS"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true
  local_user_enabled                = false
  shared_access_key_enabled         = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  sas_policy {
    expiration_period = "01.00:00:00"
  }

  tags = var.common_tags
}
