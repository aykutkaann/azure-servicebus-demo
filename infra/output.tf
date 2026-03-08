output "servicebus_connection_string" {
  description = "Service Bus connection string"
  value       = azurerm_servicebus_namespace.sb.default_primary_connection_string
  sensitive   = true  
}

output "acr_login_server" {
  description = "ACR server address"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR Username"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "ACR Password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true  
}