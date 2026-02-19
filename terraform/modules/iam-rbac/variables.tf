variable "client_id" {
  description = "Client ID of the service principal"
  type        = string
}

variable "resource_scope" {
  description = "Scope for role assignments (subscription or resource group)"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
}

variable "user_principal_id" {
  description = "Principal ID of the user for role assignment (optional)"
  type        = string
  default     = null
}

variable "create_custom_role" {
  description = "Whether to create a custom least-privilege role"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
