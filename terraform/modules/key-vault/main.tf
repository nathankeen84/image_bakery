terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "current_user_object_id" {
  description = "Object ID of current user/service principal"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to store in Key Vault (provide as map, sensitivity handled internally)"
  type        = map(string)
  default     = {}
}

# Azure Key Vault
resource "azurerm_key_vault" "bakery" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  sku_name                        = "standard"
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.current_user_object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
    ]
  }

  tags = var.common_tags
}

# Deprecated: use access_policy block within azurerm_key_vault
# If using separate access policies, use azurerm_key_vault_access_policy resource

# Store secrets
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.bakery.id

  tags = var.common_tags
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.bakery.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.bakery.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.bakery.name
}
