resource "azurerm_service_plan" "this" {
  count                  = var.create_service_plan ? 1 : 0
  name                   = coalesce(var.service_plan.name, "${var.name}-plan")
  location               = var.location
  resource_group_name    = var.rg_name
  os_type                = "Windows"
  sku_name               = var.service_plan.sku_name
  worker_count           = var.service_plan.worker_count
  zone_balancing_enabled = var.service_plan.zone_balancing_enabled
  tags                   = var.common_tags
}
