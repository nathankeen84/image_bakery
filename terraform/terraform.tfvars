subscription_id        = "d72ed3be-46f3-4feb-b6ca-53511fa25952"
location               = "eastus"
resource_group_name    = "image-bakery-rg"
gallery_name           = "imageBakeryGallery"
artifacts_storage_name = "imagebakeryartifacts"
key_vault_name         = "image-bakery-kv"

common_tags = {
  "project"     = "image-bakery"
  "environment" = "production"
  "managed_by"  = "terraform"
  "created_at"  = "2026-02-18"
}
