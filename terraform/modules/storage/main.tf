terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "storage_account_name" {
  description = "Name of the storage account"
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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Azure Storage Account for artifacts
resource "azurerm_storage_account" "artifacts" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = var.common_tags
}

# Storage container for build artifacts
resource "azurerm_storage_container" "artifacts" {
  name                  = "packer-artifacts"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

# Storage container for logs
resource "azurerm_storage_container" "logs" {
  name                  = "build-logs"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.artifacts.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.artifacts.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = azurerm_storage_account.artifacts.primary_blob_endpoint
}
