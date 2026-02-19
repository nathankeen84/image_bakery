output "service_principal_id" {
  description = "Object ID of the service principal"
  value       = azurerm_service_principal.packer.object_id
}

output "service_principal_client_id" {
  description = "Client ID of the service principal"
  value       = azurerm_service_principal.packer.client_id
}

output "custom_role_id" {
  description = "ID of the custom role (if created)"
  value       = try(azurerm_role_definition.packer_custom[0].id, null)
}
