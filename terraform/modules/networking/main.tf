terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure Virtual Network for Image Bakery
resource "azurerm_virtual_network" "bakery" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# Subnet for build resources
resource "azurerm_subnet" "build" {
  name                 = var.build_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bakery.name
  address_prefixes     = var.build_subnet_address_prefixes

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# Network Security Group for build resources
resource "azurerm_network_security_group" "build" {
  name                = var.build_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "build" {
  subnet_id                 = azurerm_subnet.build.id
  network_security_group_id = azurerm_network_security_group.build.id
}

# Network Interface for build VM
resource "azurerm_network_interface" "build" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.build.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.common_tags
}
