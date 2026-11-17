# terraform-azurerm-windows-function-app

[![Build Status](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-azurerm-windows-function-app.svg)](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-azurerm-windows-function-app.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module - Azure Windows Function App

Creates an Azure Windows Function App (azurerm_windows_function_app), optional deployment slots (azurerm_windows_function_app_slot) and an optional Windows service plan (azurerm_service_plan). Defaults are secure: HTTPS only, TLS 1.2 minimum, FTP disabled, basic auth publishing disabled, client certificates required, public network access disabled, a system assigned managed identity which is also used to reach the backing storage account (no access key), App Service Authentication (v2) enabled, remote debugging off, HTTP/2, logging and a health check. The identity needs a data role (e.g. Storage Blob Data Owner) on the storage account, as shown in the example.

---

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

## Usage

Include this repository as a module in your existing Terraform code:

```hcl
module "windows-function-app" {
  source      = "JamesWoolfenden/windows-function-app/azurerm"
  version     = "0.0.1"
  common_tags = var.common_tags
  name        = "my-function"
  rg_name     = azurerm_resource_group.example.name
  location    = azurerm_resource_group.example.location

  storage_account_name      = azurerm_storage_account.example.name
  virtual_network_subnet_id = azurerm_subnet.integration.id
}
```

The example in the **examplea** folder shows a complete deployment, including the supporting resource group, network and storage.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_windows_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [azurerm_windows_function_app_slot.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app_slot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Keep the app loaded at all times | `bool` | `true` | no |
| <a name="input_app_service_logs"></a> [app\_service\_logs](#input\_app\_service\_logs) | Function app file system logging settings | <pre>object({<br/>    disk_quota_mb         = optional(number, 35)<br/>    retention_period_days = optional(number, 7)<br/>  })</pre> | `{}` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of app settings, prefer Key Vault references to secrets | `map(string)` | `{}` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | The Application Insights connection string for the function app | `string` | `null` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | The application stack for the function app | <pre>object({<br/>    dotnet_version              = optional(string)<br/>    java_version                = optional(string)<br/>    node_version                = optional(string)<br/>    powershell_core_version     = optional(string)<br/>    use_custom_runtime          = optional(bool)<br/>    use_dotnet_isolated_runtime = optional(bool)<br/>  })</pre> | <pre>{<br/>  "dotnet_version": "v8.0",<br/>  "use_dotnet_isolated_runtime": true<br/>}</pre> | no |
| <a name="input_auth_settings_v2"></a> [auth\_settings\_v2](#input\_auth\_settings\_v2) | Authentication (Easy Auth v2) settings, enabled by default | <pre>object({<br/>    auth_enabled                   = optional(bool, true)<br/>    require_authentication         = optional(bool, true)<br/>    require_https                  = optional(bool, true)<br/>    unauthenticated_action         = optional(string, "Return401")<br/>    default_provider               = optional(string)<br/>    excluded_paths                 = optional(list(string), [])<br/>    runtime_version                = optional(string, "~1")<br/>    token_store_enabled            = optional(bool, false)<br/>    token_refresh_extension_time   = optional(number, 72)<br/>    allowed_external_redirect_urls = optional(list(string), [])<br/>    active_directory_v2 = optional(object({<br/>      client_id                            = string<br/>      tenant_auth_endpoint                 = string<br/>      client_secret_setting_name           = optional(string)<br/>      client_secret_certificate_thumbprint = optional(string)<br/>      allowed_applications                 = optional(list(string), [])<br/>      allowed_audiences                    = optional(list(string), [])<br/>      allowed_groups                       = optional(list(string), [])<br/>      allowed_identities                   = optional(list(string), [])<br/>      www_authentication_disabled          = optional(bool, false)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Backup configuration, null disables backups | <pre>object({<br/>    name                     = string<br/>    storage_account_url      = string<br/>    enabled                  = optional(bool, true)<br/>    frequency_interval       = optional(number, 1)<br/>    frequency_unit           = optional(string, "Day")<br/>    keep_at_least_one_backup = optional(bool, true)<br/>    retention_period_days    = optional(number, 30)<br/>  })</pre> | `null` | no |
| <a name="input_builtin_logging_enabled"></a> [builtin\_logging\_enabled](#input\_builtin\_logging\_enabled) | Enable built-in logging to the backing storage account (AzureWebJobsDashboard) | `bool` | `true` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Require incoming client certificates | `bool` | `true` | no |
| <a name="input_client_certificate_exclusion_paths"></a> [client\_certificate\_exclusion\_paths](#input\_client\_certificate\_exclusion\_paths) | Paths excluded from client certificate authentication, separated by ; | `string` | `null` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | The client certificate mode, one of Required, Optional, OptionalInteractiveUser | `string` | `"Required"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | This is to help you add tags to your cloud objects | `map(any)` | n/a | yes |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Connection strings for the function app, prefer Key Vault references to secrets | <pre>list(object({<br/>    name  = string<br/>    type  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Origins allowed to make cross-origin calls, empty disables the CORS block | `list(string)` | `[]` | no |
| <a name="input_cors_support_credentials"></a> [cors\_support\_credentials](#input\_cors\_support\_credentials) | Allow credentials in CORS requests | `bool` | `false` | no |
| <a name="input_create_service_plan"></a> [create\_service\_plan](#input\_create\_service\_plan) | Create a service plan for the function app, if false service\_plan\_id must be supplied | `bool` | `true` | no |
| <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled) | Allow basic authentication for FTP publishing | `bool` | `false` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | The FTP/FTPS state, one of AllAllowed, FtpsOnly, Disabled | `string` | `"Disabled"` | no |
| <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version) | The Functions runtime version | `string` | `"~4"` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | Minutes before an unhealthy instance is removed from the load balancer | `number` | `5` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The path the health check probes | `string` | `"/health"` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Enable HTTP2 | `bool` | `true` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Only allow HTTPS connections to the function app | `bool` | `true` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity for the function app | <pre>object({<br/>    type         = optional(string, "SystemAssigned")<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `{}` | no |
| <a name="input_ip_restriction_default_action"></a> [ip\_restriction\_default\_action](#input\_ip\_restriction\_default\_action) | The default action for traffic not matching an IP restriction | `string` | `"Deny"` | no |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | IP restriction rules for the function app (and the SCM site when scm\_use\_main\_ip\_restriction is true) | <pre>list(object({<br/>    name                      = string<br/>    action                    = optional(string, "Allow")<br/>    priority                  = optional(number, 100)<br/>    ip_address                = optional(string)<br/>    service_tag               = optional(string)<br/>    virtual_network_subnet_id = optional(string)<br/>    description               = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault_reference_identity_id"></a> [key\_vault\_reference\_identity\_id](#input\_key\_vault\_reference\_identity\_id) | The User Assigned Identity ID used for Key Vault references | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to deploy into | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the function app | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Windows Function App | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow public network access to the function app | `bool` | `false` | no |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Enable remote debugging | `bool` | `false` | no |
| <a name="input_remote_debugging_version"></a> [remote\_debugging\_version](#input\_remote\_debugging\_version) | The remote debugging version, only used when remote debugging is enabled | `string` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group to deploy into | `string` | n/a | yes |
| <a name="input_scm_ip_restriction_default_action"></a> [scm\_ip\_restriction\_default\_action](#input\_scm\_ip\_restriction\_default\_action) | The default action for SCM traffic not matching an IP restriction | `string` | `"Deny"` | no |
| <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version) | The minimum TLS version for the SCM (Kudu) site | `string` | `"1.2"` | no |
| <a name="input_scm_use_main_ip_restriction"></a> [scm\_use\_main\_ip\_restriction](#input\_scm\_use\_main\_ip\_restriction) | Apply the main site IP restrictions to the SCM site | `bool` | `true` | no |
| <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan) | Settings for the service plan created when create\_service\_plan is true | <pre>object({<br/>    name                   = optional(string)<br/>    sku_name               = optional(string, "P1v3")<br/>    worker_count           = optional(number, 3)<br/>    zone_balancing_enabled = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | The ID of an existing Windows service plan, used when create\_service\_plan is false | `string` | `null` | no |
| <a name="input_slots"></a> [slots](#input\_slots) | Deployment slots to create, keyed by slot name. Slots share the security settings of the main app | <pre>map(object({<br/>    app_settings        = optional(map(string), {})<br/>    auto_swap_slot_name = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_sticky_settings"></a> [sticky\_settings](#input\_sticky\_settings) | App setting and connection string names that stay with a slot during swaps | <pre>object({<br/>    app_setting_names       = optional(list(string), [])<br/>    connection_string_names = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | The backing storage account access key, only used when storage\_uses\_managed\_identity is false | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account backing the function app (AzureWebJobsStorage) | `string` | n/a | yes |
| <a name="input_storage_key_vault_secret_id"></a> [storage\_key\_vault\_secret\_id](#input\_storage\_key\_vault\_secret\_id) | A Key Vault secret ID holding the backing storage connection string, an alternative to an access key | `string` | `null` | no |
| <a name="input_storage_mounts"></a> [storage\_mounts](#input\_storage\_mounts) | Azure Files or Blob storage mounts for the function app | <pre>list(object({<br/>    name         = string<br/>    type         = optional(string, "AzureFiles")<br/>    account_name = string<br/>    share_name   = string<br/>    access_key   = string<br/>    mount_path   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_uses_managed_identity"></a> [storage\_uses\_managed\_identity](#input\_storage\_uses\_managed\_identity) | Connect to the backing storage account with the managed identity instead of an access key | `bool` | `true` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | The subnet ID used for regional VNet integration | `string` | `null` | no |
| <a name="input_vnet_route_all_enabled"></a> [vnet\_route\_all\_enabled](#input\_vnet\_route\_all\_enabled) | Route all outbound traffic through the integrated VNet | `bool` | `true` | no |
| <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled) | Allow basic authentication for WebDeploy publishing | `bool` | `false` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Enable web sockets | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_function_app"></a> [function\_app](#output\_function\_app) | The Windows Function App |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system assigned managed identity |
| <a name="output_service_plan"></a> [service\_plan](#output\_service\_plan) | The service plan, if created by the module |
| <a name="output_slots"></a> [slots](#output\_slots) | The Windows Function App deployment slots |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Policy

This is the policy required to build this project:

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang

# apply role — full permissions for terraform apply
# Bind this role to the applier SA on protected branches only.
resource "azurerm_role_definition" "terraform_pike" {
  role_definition_id = local.apply_uuid
  name               = "terraform_pike"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/providers/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Web/serverfarms/delete",
    "Microsoft.Web/serverfarms/read",
    "Microsoft.Web/serverfarms/write",
    "Microsoft.Web/sites/Delete",
    "Microsoft.Web/sites/Read",
    "Microsoft.Web/sites/Write",
    "Microsoft.Web/sites/slots/Delete",
    "Microsoft.Web/sites/slots/Read",
    "Microsoft.Web/sites/slots/Write",
    "microsoft.web/sites/operationresults/read",
    "microsoft.web/sites/slots/operationresults/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.primary.id]
}

# plan role — read-only permissions for terraform plan
# Bind this role to the planner SA on all branches.
resource "azurerm_role_definition" "terraform_pike_plan" {
  role_definition_id = local.plan_uuid
  name               = "terraform_pike_plan"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Resources/subscriptions/providers/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Web/serverfarms/read",
    "Microsoft.Web/sites/Read",
    "Microsoft.Web/sites/slots/Read",
    "microsoft.web/sites/operationresults/read",
    "microsoft.web/sites/slots/operationresults/read"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.primary.id]
}

locals {
  apply_uuid = uuid()
  plan_uuid  = uuid()
}

data "azurerm_subscription" "primary" {}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-azurerm-windows-webapp](https://github.com/jameswoolfenden/terraform-azurerm-windows-webapp) - Windows Web App
- [terraform-azurerm-linux-webapp](https://github.com/jameswoolfenden/terraform-azurerm-linux-webapp) - Linux Web App
- [terraform-azurerm-linux-function-app](https://github.com/jameswoolfenden/terraform-azurerm-linux-function-app) - Linux Function App

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/JamesWoolfenden/terraform-azurerm-windows-function-app/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
