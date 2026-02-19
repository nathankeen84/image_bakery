output "app_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.bakery.id
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.bakery.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.bakery.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.bakery.name
}
