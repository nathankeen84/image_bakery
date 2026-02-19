variable "app_insights_name" {
  description = "Name of the Application Insights instance"
  type        = string
}

variable "log_analytics_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_sku" {
  description = "SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_days" {
  description = "Retention period in days for logs"
  type        = number
  default     = 30
}

variable "key_vault_id" {
  description = "ID of the Key Vault for diagnostics"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "ID of the storage account for diagnostics"
  type        = string
  default     = null
}

variable "enable_keyvault_diagnostics" {
  description = "Enable diagnostics for Key Vault"
  type        = bool
  default     = true
}

variable "enable_storage_diagnostics" {
  description = "Enable diagnostics for storage account"
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "ID of the action group for alerts"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
