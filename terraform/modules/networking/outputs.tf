output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.bakery.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.bakery.name
}

output "build_subnet_id" {
  description = "ID of the build subnet"
  value       = azurerm_subnet.build.id
}

output "build_nsg_id" {
  description = "ID of the build Network Security Group"
  value       = azurerm_network_security_group.build.id
}

output "nic_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.build.id
}
