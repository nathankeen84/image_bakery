variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "image-bakery-rg"
}

variable "gallery_name" {
  description = "Name of the Shared Image Gallery"
  type        = string
  default     = "imageBakeryGallery"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,80}$", var.gallery_name))
    error_message = "Gallery name must be alphanumeric, 1-80 characters."
  }
}

variable "artifacts_storage_name" {
  description = "Name of the storage account for artifacts"
  type        = string
  default     = "imagebakeryartifacts"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.artifacts_storage_name))
    error_message = "Storage account name must be lowercase alphanumeric, 3-24 characters."
  }
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "image-bakery-kv"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric and hyphens only."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "project"     = "image-bakery"
    "environment" = "production"
    "managed_by"  = "terraform"
  }
}

# ============================================================================
# Packer Service Principal Secrets (DO NOT COMMIT THESE VALUES)
# Use: terraform apply -var-file=secrets.tfvars (with .gitignore protection)
# ============================================================================

variable "packer_client_id" {
  description = "Azure Service Principal Client ID for Packer"
  type        = string
  sensitive   = true
  default     = ""
}

variable "packer_client_secret" {
  description = "Azure Service Principal Client Secret for Packer"
  type        = string
  sensitive   = true
  default     = ""
}

variable "packer_tenant_id" {
  description = "Azure Tenant ID for Packer"
  type        = string
  sensitive   = true
  default     = ""
}

variable "packer_subscription_id" {
  description = "Azure Subscription ID for Packer (can be same as var.subscription_id)"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# Baseline Agent API Keys and Credentials
# Store these securely - DO NOT COMMIT
# ============================================================================

variable "qualys_api_key" {
  description = "Qualys API key for vulnerability scanning agent"
  type        = string
  sensitive   = true
  default     = ""
}

variable "qualys_api_url" {
  description = "Qualys API URL endpoint"
  type        = string
  sensitive   = true
  default     = ""
}

variable "qualys_username" {
  description = "Qualys username for agent authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "qualys_password" {
  description = "Qualys password for agent authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "nxlog_api_key" {
  description = "NXLog API key for log shipping"
  type        = string
  sensitive   = true
  default     = ""
}

variable "nxlog_endpoint" {
  description = "NXLog endpoint/collector URL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "xm_cyber_api_key" {
  description = "XM Cyber API key for attack path analysis"
  type        = string
  sensitive   = true
  default     = ""
}

variable "xm_cyber_api_url" {
  description = "XM Cyber API URL endpoint"
  type        = string
  sensitive   = true
  default     = ""
}

variable "newrelic_api_key" {
  description = "New Relic API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "newrelic_license_key" {
  description = "New Relic Infrastructure agent license key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_certificate_secret" {
  description = "Whether to upload a certificate to Key Vault"
  type        = bool
  default     = false
}

variable "certificate_path" {
  description = "Path to certificate file (if enable_certificate_secret is true)"
  type        = string
  sensitive   = true
  default     = ""
}
