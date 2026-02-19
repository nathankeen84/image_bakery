packer {
  required_version = ">= 1.15.0"
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.0"
    }
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group for build resources"
  type        = string
}

variable "gallery_name" {
  description = "Azure Compute Gallery name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Size of the build VM"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "image_offer" {
  description = "Marketplace image offer"
  type        = string
  default     = "RHEL"
}

variable "image_sku" {
  description = "Marketplace image SKU"
  type        = string
  default     = "9_1"
}

variable "image_version" {
  description = "Marketplace image version"
  type        = string
  default     = "latest"
}

variable "image_publisher" {
  description = "Marketplace image publisher"
  type        = string
  default     = "RedHat"
}

variable "build_date" {
  description = "Build date for versioning"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Agent Configuration Variables (from Key Vault)
# ============================================================================

variable "qualys_api_key" {
  description = "Qualys API key for vulnerability scanning"
  type        = string
  default     = ""
  sensitive   = true
}

variable "qualys_api_url" {
  description = "Qualys API URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "nxlog_api_key" {
  description = "NXLog API key for log shipping"
  type        = string
  default     = ""
  sensitive   = true
}

variable "nxlog_endpoint" {
  description = "NXLog collector endpoint"
  type        = string
  default     = ""
  sensitive   = true
}

variable "xm_cyber_api_key" {
  description = "XM Cyber API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "xm_cyber_api_url" {
  description = "XM Cyber API URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "newrelic_license_key" {
  description = "New Relic Infrastructure license key"
  type        = string
  default     = ""
  sensitive   = true
}

locals {
  timestamp     = regex_replace(timestamp(), "[- TZ]", "")
  image_name    = "rhel-9-cis2"
  image_version = var.build_date
}

source "azure-arm" "rhel_cis2" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  resource_group_name = var.resource_group
  location            = var.location
  vm_size             = var.vm_size

  # OS Type
  os_type = "Linux"

  # Source image configuration
  image_publisher = var.image_publisher
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  image_version   = var.image_version

  # Output configuration - publish to Compute Gallery
  shared_image_gallery_destination {
    resource_group       = var.resource_group
    gallery_name         = var.gallery_name
    image_name           = local.image_name
    image_version        = "1.0.0"
    replication_regions  = [var.location]
    storage_account_type = "Standard_ZRS"
  }

  # Also create managed image as fallback
  managed_image_name                = local.image_name
  managed_image_resource_group_name = var.resource_group

  # Allow unmanaged disks for simpler builds
  skip_create_image = false

  # Tagging
  azure_tags = merge(
    var.common_tags,
    {
      "os"             = "rhel"
      "os_version"     = "9"
      "cis_level"      = "2"
      "build_date"     = var.build_date
      "packer_version" = "1.15.0"
    }
  )
}

build {
  name = "rhel-cis2"

  sources = [
    "source.azure-arm.rhel_cis2"
  ]

  # NOTE: CIS Level 2 is INCREMENTAL on Level 1.
  # Build from CIS L1 baseline first, then apply L2 controls.
  # Do not duplicate L1 controls here.

  # Provisioner 1: System updates and package installation
  provisioner "shell" {
    inline = [
      "echo '=== Starting RHEL CIS L2 Build (Incremental on L1) ==='",
      "sudo yum update -y",
      "sudo yum install -y curl wget git unzip ca-certificates"
    ]
  }

  # Provisioner 2: CIS L1 Hardening (baseline)
  provisioner "shell" {
    script = "${path.root}/../../../shared/scripts/hardening/cis1/rhel-cis1-hardening.sh"
  }

  # Provisioner 3: CIS L2 Hardening (incremental)
  provisioner "shell" {
    script = "${path.root}/../../../shared/scripts/hardening/cis2/rhel-cis2-hardening.sh"
  }

  # Provisioner 4: OS Configuration
  provisioner "shell" {
    inline = [
      "echo '=== Applying OS Configuration ==='",
      "sudo timedatectl set-timezone UTC",
      "sudo systemctl set-default multi-user.target"
    ]
  }

  # Provisioner 5: Install Baseline Agents (with secrets from Key Vault)
  provisioner "shell" {
    environment_vars = [
      "QUALYS_API_KEY=${var.qualys_api_key}",
      "QUALYS_API_URL=${var.qualys_api_url}",
      "NXLOG_API_KEY=${var.nxlog_api_key}",
      "NXLOG_ENDPOINT=${var.nxlog_endpoint}",
      "XM_CYBER_API_KEY=${var.xm_cyber_api_key}",
      "XM_CYBER_API_URL=${var.xm_cyber_api_url}",
      "NEWRELIC_LICENSE_KEY=${var.newrelic_license_key}"
    ]
    script = "${path.root}/../../../shared/scripts/agents/install-baseline-agents.sh"
  }

  # Provisioner 6: Cleanup and finalization
  provisioner "shell" {
    inline = [
      "echo '=== Cleanup and Finalization ==='",
      "sudo yum clean all",
      "sudo rm -rf /tmp/*",
      "sudo waagent -force -deprovision+user",
      "export HISTSIZE=0",
      "sync"
    ]
  }
}
