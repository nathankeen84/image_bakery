terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

# Data source for current Azure context
data "azurerm_client_config" "current" {}

# ============================================================================
# Resource Group Module
# ============================================================================
module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  common_tags         = var.common_tags
}

# ============================================================================
# Compute Gallery Module
# ============================================================================
module "compute_gallery" {
  source = "./modules/compute-gallery"

  gallery_name        = var.gallery_name
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  common_tags         = var.common_tags

  image_definitions = [
    # Ubuntu Images
    {
      name        = "ubuntu-2204-cis1"
      offer       = "ubuntu"
      sku         = "2204-cis1"
      os_type     = "Linux"
      description = "Ubuntu 22.04 LTS with CIS Level 1 hardening"
      os_version  = "22.04"
      cis_level   = "1"
    },
    {
      name        = "ubuntu-2204-cis2"
      offer       = "ubuntu"
      sku         = "2204-cis2"
      os_type     = "Linux"
      description = "Ubuntu 22.04 LTS with CIS Level 2 hardening"
      os_version  = "22.04"
      cis_level   = "2"
    },
    # Windows Server Images
    {
      name        = "windows-2022-cis1"
      offer       = "windows"
      sku         = "2022-cis1"
      os_type     = "Windows"
      description = "Windows Server 2022 with CIS Level 1 hardening"
      os_version  = "2022"
      cis_level   = "1"
    },
    {
      name        = "windows-2022-cis2"
      offer       = "windows"
      sku         = "2022-cis2"
      os_type     = "Windows"
      description = "Windows Server 2022 with CIS Level 2 hardening"
      os_version  = "2022"
      cis_level   = "2"
    },
    # Azure Linux Images
    {
      name        = "azurelinux-3-cis1"
      offer       = "azurelinux"
      sku         = "3-cis1"
      os_type     = "Linux"
      description = "Azure Linux 3.0 with CIS Level 1 hardening"
      os_version  = "3.0"
      cis_level   = "1"
    },
    {
      name        = "azurelinux-3-cis2"
      offer       = "azurelinux"
      sku         = "3-cis2"
      os_type     = "Linux"
      description = "Azure Linux 3.0 with CIS Level 2 hardening"
      os_version  = "3.0"
      cis_level   = "2"
    },
    # RHEL Images
    {
      name        = "rhel-9-cis1"
      offer       = "rhel"
      sku         = "9-cis1"
      os_type     = "Linux"
      description = "Red Hat Enterprise Linux 9 with CIS Level 1 hardening"
      os_version  = "9"
      cis_level   = "1"
    },
    {
      name        = "rhel-9-cis2"
      offer       = "rhel"
      sku         = "9-cis2"
      os_type     = "Linux"
      description = "Red Hat Enterprise Linux 9 with CIS Level 2 hardening"
      os_version  = "9"
      cis_level   = "2"
    }
  ]
}

# ============================================================================
# Storage Module
# ============================================================================
module "storage" {
  source = "./modules/storage"

  storage_account_name = replace(var.artifacts_storage_name, "-", "")
  resource_group_name  = module.resource_group.resource_group_name
  location             = var.location
  common_tags          = var.common_tags
}

# ============================================================================
# Key Vault Module
# ============================================================================
module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name         = var.key_vault_name
  resource_group_name    = module.resource_group.resource_group_name
  location               = var.location
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id
  common_tags            = var.common_tags

  secrets = {
    "packer-client-id"       = var.packer_client_id
    "packer-client-secret"   = var.packer_client_secret
    "packer-tenant-id"       = var.packer_tenant_id
    "packer-subscription-id" = var.packer_subscription_id
    "qualys-api-key"         = var.qualys_api_key
    "qualys-api-url"         = var.qualys_api_url
    "qualys-username"        = var.qualys_username
    "qualys-password"        = var.qualys_password
    "nxlog-api-key"          = var.nxlog_api_key
    "nxlog-endpoint"         = var.nxlog_endpoint
    "xm-cyber-api-key"       = var.xm_cyber_api_key
    "xm-cyber-api-url"       = var.xm_cyber_api_url
    "newrelic-api-key"       = var.newrelic_api_key
    "newrelic-license-key"   = var.newrelic_license_key
  }
}

# ============================================================================
# Outputs
# ============================================================================
output "gallery_id" {
  description = "ID of the created Shared Image Gallery"
  value       = module.compute_gallery.gallery_id
}

output "gallery_name" {
  description = "Name of the created Shared Image Gallery"
  value       = module.compute_gallery.gallery_name
}

output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = module.resource_group.resource_group_name
}

output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "storage_account_name" {
  description = "Name of the artifacts storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "ID of the artifacts storage account"
  value       = module.storage.storage_account_id
}
