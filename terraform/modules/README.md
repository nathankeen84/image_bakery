# Terraform Modules for Image Bakery

This directory contains reusable Terraform modules for Image Bakery infrastructure.

## Modules

### compute-gallery

Manages Azure Shared Image Gallery for storing and versioning hardened VM images.

**Resources**:

- azurerm_shared_image_gallery
- azurerm_shared_image (image definitions)

### key-vault

Manages Azure Key Vault for storing secrets securely.

**Resources**:

- azurerm_key_vault
- azurerm_key_vault_secret

### storage

Manages Azure Storage Account for build artifacts.

**Resources**:

- azurerm_storage_account
- azurerm_storage_container

### resource-group

Manages Azure Resource Group as container for all resources.

**Resources**:

- azurerm_resource_group
