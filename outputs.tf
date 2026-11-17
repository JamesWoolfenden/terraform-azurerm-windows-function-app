output "function_app" {
  description = "The Windows Function App"
  value       = azurerm_windows_function_app.this
  sensitive   = true
}

output "slots" {
  description = "The Windows Function App deployment slots"
  value       = azurerm_windows_function_app_slot.this
  sensitive   = true
}

output "service_plan" {
  description = "The service plan, if created by the module"
  value       = one(azurerm_service_plan.this)
}

output "principal_id" {
  description = "The principal ID of the system assigned managed identity"
  value       = azurerm_windows_function_app.this.identity[0].principal_id
}
