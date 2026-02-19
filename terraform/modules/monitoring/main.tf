terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Application Insights for monitoring Image Bakery operations
resource "azurerm_application_insights" "bakery" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.common_tags
}

# Log Analytics Workspace for centralized logging
resource "azurerm_log_analytics_workspace" "bakery" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_days

  tags = var.common_tags
}

# Diagnostic setting for Key Vault
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  count                      = var.enable_keyvault_diagnostics ? 1 : 0
  name                       = "keyvault-diagnostics"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bakery.id

  enabled_log {
    category = "AuditEvent"
  }

}

# Diagnostic setting for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count                      = var.enable_storage_diagnostics ? 1 : 0
  name                       = "storage-diagnostics"
  target_resource_id         = var.storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bakery.id

}

# Alert for high error rate in operations
resource "azurerm_monitor_metric_alert" "high_errors" {
  count               = var.enable_alerts ? 1 : 0
  name                = "image-bakery-high-errors"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.bakery.id]
  description         = "Alert when error rate is high"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "failedRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = var.action_group_id != null ? var.action_group_id : null
  }

  tags = var.common_tags
}
