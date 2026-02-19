# Key Vault Secrets Management for Image Bakery
# DEPRECATED: All secrets are now managed through the key-vault module
# Individual resource definitions have been removed - use the key-vault module instead
#
# To add a new secret:
# 1. Add variable in variables.tf (marked as sensitive)
# 2. Add to secrets map in key-vault module call in main.tf
# 3. Provide value via terraform.tfvars or -var flag
#
# Secrets are stored in Key Vault via module.key_vault.key_vault_id
# Reference secrets in Packer: module.key_vault.secrets[key_name]

# SSH/TLS Certificates (if needed)
# Optional: Generate certificate for build VM authentication
# To use: set enable_certificate_secret=true and provide path to certificate file
# resource "azurerm_key_vault_certificate" "build_certificate" {
#   count        = var.enable_certificate_secret ? 1 : 0
#   name         = "image-bakery-cert"
#   key_vault_id = azurerm_key_vault.bakery.id
#
#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }
#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = true
#     }
#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#     x509_certificate_properties {
#       subject = "CN=ImageBakery"
#       validity_in_months = 12
#     }
#   }
#
#   tags = var.common_tags
# }

# Note: Outputs are defined in main.tf to avoid duplication
