resource "azurerm_windows_function_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  service_plan_id     = var.create_service_plan ? azurerm_service_plan.this[0].id : var.service_plan_id

  storage_account_name          = var.storage_account_name
  storage_uses_managed_identity = var.storage_uses_managed_identity
  storage_account_access_key    = var.storage_uses_managed_identity ? null : var.storage_account_access_key
  storage_key_vault_secret_id   = var.storage_key_vault_secret_id
  functions_extension_version   = var.functions_extension_version
  builtin_logging_enabled       = var.builtin_logging_enabled

  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  app_settings                                   = var.app_settings

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  site_config {
    always_on                              = var.always_on
    ftps_state                             = var.ftps_state
    http2_enabled                          = var.http2_enabled
    minimum_tls_version                    = var.minimum_tls_version
    scm_minimum_tls_version                = var.scm_minimum_tls_version
    remote_debugging_enabled               = var.remote_debugging_enabled
    remote_debugging_version               = var.remote_debugging_version
    health_check_path                      = var.health_check_path
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    websockets_enabled                     = var.websockets_enabled
    ip_restriction_default_action          = var.ip_restriction_default_action
    scm_ip_restriction_default_action      = var.scm_ip_restriction_default_action
    scm_use_main_ip_restriction            = var.scm_use_main_ip_restriction
    application_insights_connection_string = var.application_insights_connection_string

    application_stack {
      dotnet_version              = var.application_stack.dotnet_version
      java_version                = var.application_stack.java_version
      node_version                = var.application_stack.node_version
      powershell_core_version     = var.application_stack.powershell_core_version
      use_custom_runtime          = var.application_stack.use_custom_runtime
      use_dotnet_isolated_runtime = var.application_stack.use_dotnet_isolated_runtime
    }

    app_service_logs {
      disk_quota_mb         = var.app_service_logs.disk_quota_mb
      retention_period_days = var.app_service_logs.retention_period_days
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        action                    = ip_restriction.value.action
        priority                  = ip_restriction.value.priority
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        description               = ip_restriction.value.description
      }
    }

    dynamic "cors" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  auth_settings_v2 {
    auth_enabled           = var.auth_settings_v2.auth_enabled
    require_authentication = var.auth_settings_v2.require_authentication
    require_https          = var.auth_settings_v2.require_https
    unauthenticated_action = var.auth_settings_v2.unauthenticated_action
    default_provider       = var.auth_settings_v2.default_provider
    excluded_paths         = var.auth_settings_v2.excluded_paths
    runtime_version        = var.auth_settings_v2.runtime_version

    login {
      token_store_enabled            = var.auth_settings_v2.token_store_enabled
      token_refresh_extension_time   = var.auth_settings_v2.token_refresh_extension_time
      allowed_external_redirect_urls = var.auth_settings_v2.allowed_external_redirect_urls
    }

    dynamic "active_directory_v2" {
      for_each = var.auth_settings_v2.active_directory_v2 == null ? [] : [var.auth_settings_v2.active_directory_v2]
      content {
        client_id                            = active_directory_v2.value.client_id
        tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
        client_secret_setting_name           = active_directory_v2.value.client_secret_setting_name
        client_secret_certificate_thumbprint = active_directory_v2.value.client_secret_certificate_thumbprint
        allowed_applications                 = active_directory_v2.value.allowed_applications
        allowed_audiences                    = active_directory_v2.value.allowed_audiences
        allowed_groups                       = active_directory_v2.value.allowed_groups
        allowed_identities                   = active_directory_v2.value.allowed_identities
        www_authentication_disabled          = active_directory_v2.value.www_authentication_disabled
      }
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts
    content {
      name         = storage_account.value.name
      type         = storage_account.value.type
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = storage_account.value.access_key
      mount_path   = storage_account.value.mount_path
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]
    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      enabled             = backup.value.enabled
      schedule {
        frequency_interval       = backup.value.frequency_interval
        frequency_unit           = backup.value.frequency_unit
        keep_at_least_one_backup = backup.value.keep_at_least_one_backup
        retention_period_days    = backup.value.retention_period_days
      }
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings == null ? [] : [var.sticky_settings]
    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  tags = var.common_tags
}
