# Common variables for all Image Bakery Packer builds
# These values can be overridden with -var flag during packer build

# Azure Authentication (from Key Vault via environment variables or -var flag)
# Export from Key Vault: source shared/scripts/retrieve-keyvault-secrets.sh
subscription_id = "YOUR_SUBSCRIPTION_ID"

# Azure Subscription and Gallery
resource_group  = "image-bakery-rg"
gallery_name    = "imageBakeryGallery"
location        = "eastus"

# Image metadata
image_publisher = "ImageBakery"
build_date      = "2026-02-18"

# Azure Build VM configuration
vm_size = "Standard_D4s_v3"

# Tags applied to all resources
common_tags = {
  "project"     = "image-bakery"
  "environment" = "production"
  "managed_by"  = "packer"
}
