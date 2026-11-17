variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(any)

  validation {
    condition     = alltrue([for k, v in var.common_tags : length(k) <= 512 && length(tostring(v)) <= 256])
    error_message = "common_tags keys must be at most 512 characters and values at most 256 characters."
  }
}

variable "name" {
  description = "The name of the Windows Function App"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$", var.name))
    error_message = "name must be 2-60 characters of letters, digits and hyphens, starting and ending with a letter or digit."
  }
}

variable "rg_name" {
  description = "The name of the resource group to deploy into"
  type        = string

  validation {
    condition     = can(regex("^[-\\w\\.\\(\\)]{1,89}[-\\w\\(\\)]$", var.rg_name))
    error_message = "rg_name must be a valid resource group name of 1-90 characters."
  }
}

variable "location" {
  description = "The Azure region to deploy into"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "location must not be empty."
  }
}

variable "create_service_plan" {
  description = "Create a service plan for the function app, if false service_plan_id must be supplied"
  type        = bool
  default     = true
}

variable "service_plan_id" {
  description = "The ID of an existing Windows service plan, used when create_service_plan is false"
  type        = string
  default     = null

  validation {
    condition     = var.service_plan_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Web/serverFarms/[^/]+$", var.service_plan_id))
    error_message = "service_plan_id must be null or an App Service plan resource ID."
  }
}

variable "service_plan" {
  description = "Settings for the service plan created when create_service_plan is true"
  type = object({
    name                   = optional(string)
    sku_name               = optional(string, "P1v3")
    worker_count           = optional(number, 3)
    zone_balancing_enabled = optional(bool, true)
  })
  default = {}

  validation {
    condition     = can(regex("^(B[1-3]|S[1-3]|P[0-3]v[2-4]|P[0-3]mv[3-4]|I[1-6]v2|I[1-5]mv2|EP[1-3]|Y1|FC1|F1|D1)$", var.service_plan.sku_name)) && var.service_plan.worker_count >= 1
    error_message = "service_plan.sku_name must be a valid App Service plan SKU and worker_count at least 1."
  }
}

variable "https_only" {
  description = "Only allow HTTPS connections to the function app"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the function app"
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Require incoming client certificates"
  type        = bool
  default     = true
}

variable "client_certificate_mode" {
  description = "The client certificate mode, one of Required, Optional, OptionalInteractiveUser"
  type        = string
  default     = "Required"

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional or OptionalInteractiveUser."
  }
}

variable "client_certificate_exclusion_paths" {
  description = "Paths excluded from client certificate authentication, separated by ;"
  type        = string
  default     = null

  validation {
    condition     = var.client_certificate_exclusion_paths == null || can(regex("^/", var.client_certificate_exclusion_paths))
    error_message = "client_certificate_exclusion_paths must be null or ;-separated paths starting with /."
  }
}

variable "ftp_publish_basic_authentication_enabled" {
  description = "Allow basic authentication for FTP publishing"
  type        = bool
  default     = false
}

variable "webdeploy_publish_basic_authentication_enabled" {
  description = "Allow basic authentication for WebDeploy publishing"
  type        = bool
  default     = false
}

variable "key_vault_reference_identity_id" {
  description = "The User Assigned Identity ID used for Key Vault references"
  type        = string
  default     = null

  validation {
    condition     = var.key_vault_reference_identity_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[^/]+$", var.key_vault_reference_identity_id))
    error_message = "key_vault_reference_identity_id must be null or a user assigned identity resource ID."
  }
}

variable "virtual_network_subnet_id" {
  description = "The subnet ID used for regional VNet integration"
  type        = string
  default     = null

  validation {
    condition     = var.virtual_network_subnet_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.virtual_network_subnet_id))
    error_message = "virtual_network_subnet_id must be null or a subnet resource ID."
  }
}

variable "identity" {
  description = "Managed identity for the function app"
  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string))
  })
  default = {}

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned or \"SystemAssigned, UserAssigned\"."
  }
}

variable "app_settings" {
  description = "A map of app settings, prefer Key Vault references to secrets"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.app_settings) : can(regex("^[A-Za-z0-9_.:-]+$", k))])
    error_message = "app_settings keys may only contain letters, digits, underscores, periods, colons and hyphens."
  }
}

variable "connection_strings" {
  description = "Connection strings for the function app, prefer Key Vault references to secrets"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []

  validation {
    condition     = alltrue([for c in var.connection_strings : contains(["APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer"], c.type)])
    error_message = "connection_strings type must be a valid App Service connection string type."
  }
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the function app"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.2 or 1.3."
  }
}

variable "scm_minimum_tls_version" {
  description = "The minimum TLS version for the SCM (Kudu) site"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.scm_minimum_tls_version)
    error_message = "scm_minimum_tls_version must be 1.2 or 1.3."
  }
}

variable "ftps_state" {
  description = "The FTP/FTPS state, one of AllAllowed, FtpsOnly, Disabled"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be FtpsOnly or Disabled; plain FTP is not allowed."
  }
}

variable "http2_enabled" {
  description = "Enable HTTP2"
  type        = bool
  default     = true
}

variable "remote_debugging_enabled" {
  description = "Enable remote debugging"
  type        = bool
  default     = false
}

variable "remote_debugging_version" {
  description = "The remote debugging version, only used when remote debugging is enabled"
  type        = string
  default     = null

  validation {
    condition     = var.remote_debugging_version == null || contains(["VS2022"], var.remote_debugging_version)
    error_message = "remote_debugging_version must be null or VS2022."
  }
}

variable "always_on" {
  description = "Keep the app loaded at all times"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "The path the health check probes"
  type        = string
  default     = "/health"

  validation {
    condition     = can(regex("^/", var.health_check_path))
    error_message = "health_check_path must start with /."
  }
}

variable "health_check_eviction_time_in_min" {
  description = "Minutes before an unhealthy instance is removed from the load balancer"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_eviction_time_in_min >= 2 && var.health_check_eviction_time_in_min <= 10
    error_message = "health_check_eviction_time_in_min must be between 2 and 10."
  }
}

variable "vnet_route_all_enabled" {
  description = "Route all outbound traffic through the integrated VNet"
  type        = bool
  default     = true
}

variable "websockets_enabled" {
  description = "Enable web sockets"
  type        = bool
  default     = false
}

variable "ip_restriction_default_action" {
  description = "The default action for traffic not matching an IP restriction"
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.ip_restriction_default_action)
    error_message = "ip_restriction_default_action must be Allow or Deny."
  }
}

variable "scm_ip_restriction_default_action" {
  description = "The default action for SCM traffic not matching an IP restriction"
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.scm_ip_restriction_default_action)
    error_message = "scm_ip_restriction_default_action must be Allow or Deny."
  }
}

variable "scm_use_main_ip_restriction" {
  description = "Apply the main site IP restrictions to the SCM site"
  type        = bool
  default     = true
}

variable "ip_restrictions" {
  description = "IP restriction rules for the function app (and the SCM site when scm_use_main_ip_restriction is true)"
  type = list(object({
    name                      = string
    action                    = optional(string, "Allow")
    priority                  = optional(number, 100)
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    description               = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.ip_restrictions : contains(["Allow", "Deny"], r.action) && r.ip_address != "0.0.0.0/0" && r.ip_address != "*"])
    error_message = "ip_restrictions action must be Allow or Deny and ip_address must not be 0.0.0.0/0 or *."
  }
}

variable "cors_allowed_origins" {
  description = "Origins allowed to make cross-origin calls, empty disables the CORS block"
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.cors_allowed_origins, "*")
    error_message = "cors_allowed_origins must not contain the wildcard origin *."
  }
}

variable "cors_support_credentials" {
  description = "Allow credentials in CORS requests"
  type        = bool
  default     = false
}

variable "auth_settings_v2" {
  description = "Authentication (Easy Auth v2) settings, enabled by default"
  type = object({
    auth_enabled                   = optional(bool, true)
    require_authentication         = optional(bool, true)
    require_https                  = optional(bool, true)
    unauthenticated_action         = optional(string, "Return401")
    default_provider               = optional(string)
    excluded_paths                 = optional(list(string), [])
    runtime_version                = optional(string, "~1")
    token_store_enabled            = optional(bool, false)
    token_refresh_extension_time   = optional(number, 72)
    allowed_external_redirect_urls = optional(list(string), [])
    active_directory_v2 = optional(object({
      client_id                            = string
      tenant_auth_endpoint                 = string
      client_secret_setting_name           = optional(string)
      client_secret_certificate_thumbprint = optional(string)
      allowed_applications                 = optional(list(string), [])
      allowed_audiences                    = optional(list(string), [])
      allowed_groups                       = optional(list(string), [])
      allowed_identities                   = optional(list(string), [])
      www_authentication_disabled          = optional(bool, false)
    }))
  })
  default = {}

  validation {
    condition     = contains(["RedirectToLoginPage", "AllowAnonymous", "Return401", "Return403", "Return404"], var.auth_settings_v2.unauthenticated_action)
    error_message = "auth_settings_v2.unauthenticated_action must be RedirectToLoginPage, AllowAnonymous, Return401, Return403 or Return404."
  }
}

variable "storage_mounts" {
  description = "Azure Files or Blob storage mounts for the function app"
  type = list(object({
    name         = string
    type         = optional(string, "AzureFiles")
    account_name = string
    share_name   = string
    access_key   = string
    mount_path   = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for m in var.storage_mounts : contains(["AzureFiles", "AzureBlob"], m.type)])
    error_message = "storage_mounts type must be AzureFiles or AzureBlob."
  }
}

variable "backup" {
  description = "Backup configuration, null disables backups"
  type = object({
    name                     = string
    storage_account_url      = string
    enabled                  = optional(bool, true)
    frequency_interval       = optional(number, 1)
    frequency_unit           = optional(string, "Day")
    keep_at_least_one_backup = optional(bool, true)
    retention_period_days    = optional(number, 30)
  })
  default = null

  validation {
    condition     = var.backup == null || try(contains(["Day", "Hour"], var.backup.frequency_unit), false)
    error_message = "backup.frequency_unit must be Day or Hour."
  }
}

variable "sticky_settings" {
  description = "App setting and connection string names that stay with a slot during swaps"
  type = object({
    app_setting_names       = optional(list(string), [])
    connection_string_names = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.sticky_settings == null || try(length(var.sticky_settings.app_setting_names) + length(var.sticky_settings.connection_string_names) > 0, false)
    error_message = "sticky_settings must list at least one app setting or connection string name, or be null."
  }
}

variable "slots" {
  description = "Deployment slots to create, keyed by slot name. Slots share the security settings of the main app"
  type = map(object({
    app_settings        = optional(map(string), {})
    auto_swap_slot_name = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.slots) : can(regex("^[a-z0-9-]{1,59}$", k))])
    error_message = "slot names must be 1-59 lowercase letters, digits and hyphens."
  }
}

variable "storage_account_name" {
  description = "The name of the storage account backing the function app (AzureWebJobsStorage)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase letters and digits."
  }
}

variable "storage_uses_managed_identity" {
  description = "Connect to the backing storage account with the managed identity instead of an access key"
  type        = bool
  default     = true
}

variable "storage_account_access_key" {
  description = "The backing storage account access key, only used when storage_uses_managed_identity is false"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.storage_account_access_key == null || can(base64decode(var.storage_account_access_key))
    error_message = "storage_account_access_key must be null or a base64 storage account key."
  }
}

variable "storage_key_vault_secret_id" {
  description = "A Key Vault secret ID holding the backing storage connection string, an alternative to an access key"
  type        = string
  default     = null

  validation {
    condition     = var.storage_key_vault_secret_id == null || can(regex("^https://[a-zA-Z0-9-]+\\.vault\\.azure\\.net/secrets/", var.storage_key_vault_secret_id))
    error_message = "storage_key_vault_secret_id must be null or a Key Vault secret URI."
  }
}

variable "functions_extension_version" {
  description = "The Functions runtime version"
  type        = string
  default     = "~4"

  validation {
    condition     = can(regex("^~[0-9]+$", var.functions_extension_version))
    error_message = "functions_extension_version must look like ~4."
  }
}

variable "builtin_logging_enabled" {
  description = "Enable built-in logging to the backing storage account (AzureWebJobsDashboard)"
  type        = bool
  default     = true
}

variable "application_insights_connection_string" {
  description = "The Application Insights connection string for the function app"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.application_insights_connection_string == null || can(regex("InstrumentationKey=", var.application_insights_connection_string))
    error_message = "application_insights_connection_string must be null or an Application Insights connection string."
  }
}

variable "app_service_logs" {
  description = "Function app file system logging settings"
  type = object({
    disk_quota_mb         = optional(number, 35)
    retention_period_days = optional(number, 7)
  })
  default = {}

  validation {
    condition     = var.app_service_logs.disk_quota_mb >= 25 && var.app_service_logs.disk_quota_mb <= 100 && var.app_service_logs.retention_period_days >= 1
    error_message = "app_service_logs.disk_quota_mb must be between 25 and 100 and retention_period_days at least 1."
  }
}

variable "application_stack" {
  description = "The application stack for the function app"
  type = object({
    dotnet_version              = optional(string)
    java_version                = optional(string)
    node_version                = optional(string)
    powershell_core_version     = optional(string)
    use_custom_runtime          = optional(bool)
    use_dotnet_isolated_runtime = optional(bool)
  })
  default = {
    dotnet_version              = "v8.0"
    use_dotnet_isolated_runtime = true
  }

  validation {
    condition     = length([for v in values(var.application_stack) : v if v != null]) > 0
    error_message = "application_stack must set at least one runtime."
  }
}
