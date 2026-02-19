terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "gallery_name" {
  description = "Name of the Shared Image Gallery"
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

variable "image_definitions" {
  description = "Image definitions to create (OS + CIS level combinations)"
  type = list(object({
    name        = string
    offer       = string
    sku         = string
    os_type     = string
    description = string
    os_version  = string
    cis_level   = string
  }))
  default = []
}

# Azure Compute Gallery
resource "azurerm_shared_image_gallery" "bakery" {
  name                = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location

  description = "Shared Image Gallery for hardened Azure VM images (CIS compliant)"

  tags = var.common_tags
}

# Image Definitions (Ubuntu, Windows, Azure Linux, RHEL)
resource "azurerm_shared_image" "images" {
  for_each = {
    for img in var.image_definitions : "${img.offer}-${img.sku}" => img
  }

  name                = each.value.name
  gallery_name        = azurerm_shared_image_gallery.bakery.name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type            = each.value.os_type
  hyper_v_generation = "V2"

  identifier {
    publisher = "ImageBakery"
    offer     = each.value.offer
    sku       = each.value.sku
  }

  description = each.value.description

  tags = merge(
    var.common_tags,
    {
      "os"         = each.value.offer
      "os_version" = each.value.os_version
      "cis_level"  = each.value.cis_level
    }
  )
}

output "gallery_id" {
  description = "ID of the Shared Image Gallery"
  value       = azurerm_shared_image_gallery.bakery.id
}

output "gallery_name" {
  description = "Name of the Shared Image Gallery"
  value       = azurerm_shared_image_gallery.bakery.name
}

output "image_definitions" {
  description = "Created image definitions"
  value = {
    for k, v in azurerm_shared_image.images : k => {
      id   = v.id
      name = v.name
    }
  }
}
