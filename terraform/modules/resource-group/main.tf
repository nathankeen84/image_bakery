terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
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

# Azure Resource Group
resource "azurerm_resource_group" "image_bakery" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.image_bakery.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.image_bakery.name
}
