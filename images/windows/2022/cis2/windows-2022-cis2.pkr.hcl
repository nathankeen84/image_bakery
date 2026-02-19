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
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "Marketplace image SKU"
  type        = string
  default     = "2022-datacenter-g2"
}

variable "image_version" {
  description = "Marketplace image version"
  type        = string
  default     = "latest"
}

variable "image_publisher" {
  description = "Marketplace image publisher"
  type        = string
  default     = "MicrosoftWindowsServer"
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
  image_name    = "windows-2022-cis2"
  image_version = var.build_date
}

source "azure-arm" "windows_cis2" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  resource_group_name = var.resource_group
  location            = var.location
  vm_size             = var.vm_size

  # OS Type
  os_type = "Windows"

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
      "os"             = "windows"
      "os_version"     = "2022"
      "cis_level"      = "2"
      "build_date"     = var.build_date
      "packer_version" = "1.15.0"
    }
  )
}

build {
  name = "windows-cis2"

  sources = [
    "source.azure-arm.windows_cis2"
  ]

  # NOTE: CIS Level 2 is INCREMENTAL on Level 1.
  # Build from CIS L1 baseline first, then apply L2 controls.
  # Do not duplicate L1 controls here.

  # Provisioner 1: System updates and prerequisites
  provisioner "powershell" {
    inline = [
      "Write-Host '=== Starting Windows CIS L2 Build (Incremental on L1) ===' -ForegroundColor Green",
      "$ErrorActionPreference = 'Stop'",
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "Write-Host 'Windows Update: Installing pending updates...'",
      "Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property csname, Description, InstallDate"
    ]
  }

  # Provisioner 2: CIS L1 Hardening (baseline)
  provisioner "powershell" {
    script = "${path.root}/../../../shared/scripts/hardening/cis1/windows-cis1-hardening.ps1"
  }

  # Provisioner 3: CIS L2 Hardening (incremental)
  provisioner "powershell" {
    script = "${path.root}/../../../shared/scripts/hardening/cis2/windows-cis2-hardening.ps1"
  }

  # Provisioner 4: OS Configuration
  provisioner "powershell" {
    inline = [
      "Write-Host '=== Applying OS Configuration ===' -ForegroundColor Green",
      "Set-TimeZone -Name 'UTC' -PassThru",
      "New-Item -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System' -Force | Out-Null",
      "Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\System' -Name 'LocalAccountTokenFilterPolicy' -Value 1 -Force"
    ]
  }

  # Provisioner 5: Install Baseline Agents (with secrets from Key Vault)
  provisioner "powershell" {
    environment_vars = [
      "QUALYS_API_KEY=${var.qualys_api_key}",
      "QUALYS_API_URL=${var.qualys_api_url}",
      "NXLOG_API_KEY=${var.nxlog_api_key}",
      "NXLOG_ENDPOINT=${var.nxlog_endpoint}",
      "XM_CYBER_API_KEY=${var.xm_cyber_api_key}",
      "XM_CYBER_API_URL=${var.xm_cyber_api_url}",
      "NEWRELIC_LICENSE_KEY=${var.newrelic_license_key}"
    ]
    script = "${path.root}/../../../shared/scripts/agents/install-baseline-agents.ps1"
  }

  # Provisioner 6: Cleanup and finalization
  provisioner "powershell" {
    inline = [
      "Write-Host '=== Cleanup and Finalization ===' -ForegroundColor Green",
      "Remove-Item -Path 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Remove-Item -Path 'C:\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Invoke-Command -ScriptBlock { Get-EventLog -LogName System -Newest 1000 | Remove-EventLog -ErrorAction SilentlyContinue }",
      "Write-Host 'Windows CIS L2 image build completed successfully' -ForegroundColor Green"
    ]
  }
}
