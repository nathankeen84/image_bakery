terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Data source to reference existing service principal by application ID
data "azuread_service_principal" "packer" {
  client_id = var.client_id
}

# Role assignment: Contributor role for Packer service principal
resource "azurerm_role_assignment" "packer_contributor" {
  scope                = var.resource_scope
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.packer.object_id
}

# Role assignment: Storage Blob Data Contributor
resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.packer.object_id
}

# Role assignment: Key Vault Secrets Officer for managing secrets
resource "azurerm_role_assignment" "keyvault_officer" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_service_principal.packer.object_id
}

# User role assignment (optional - for manual deployments)
resource "azurerm_role_assignment" "user_contributor" {
  count                = var.user_principal_id != null ? 1 : 0
  scope                = var.resource_scope
  role_definition_name = "Contributor"
  principal_id         = var.user_principal_id
}

# Custom role for least privilege access (optional)
resource "azurerm_role_definition" "packer_custom" {
  count       = var.create_custom_role ? 1 : 0
  name        = "PackerImageBuilder"
  scope       = var.resource_scope
  description = "Custom role for Packer image building with least privilege"

  permissions {
    actions = [
      "Microsoft.Compute/galleries/*/read",
      "Microsoft.Compute/galleries/*/write",
      "Microsoft.Compute/galleries/images/versions/*/write",
      "Microsoft.Storage/storageAccounts/*/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.KeyVault/vaults/read",
      "Microsoft.KeyVault/vaults/secrets/getSecret/action"
    ]
    not_actions = []
  }

  assignable_scopes = [var.resource_scope]
}

# Assign custom role if created
resource "azurerm_role_assignment" "packer_custom_role" {
  count              = var.create_custom_role ? 1 : 0
  scope              = var.resource_scope
  role_definition_id = azurerm_role_definition.packer_custom[0].role_definition_resource_id
  principal_id       = data.azuread_service_principal.packer.object_id
}
