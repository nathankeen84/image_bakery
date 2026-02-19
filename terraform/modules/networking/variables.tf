variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "build_subnet_name" {
  description = "Name of the build subnet"
  type        = string
  default     = "build-subnet"
}

variable "build_subnet_address_prefixes" {
  description = "Address prefixes for build subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "build_nsg_name" {
  description = "Name of the build Network Security Group"
  type        = string
  default     = "build-nsg"
}

variable "nic_name" {
  description = "Name of the network interface"
  type        = string
  default     = "build-nic"
}

variable "public_ip_id" {
  description = "ID of public IP address (optional)"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
