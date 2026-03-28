output "resource_group_name" {
  description = "Resource group name for the prod environment."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "Virtual network ID for the prod environment."
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by logical subnet name."
  value       = module.vnet.subnet_ids
}

output "storage_account_name" {
  description = "Storage account name for the prod environment."
  value       = azurerm_storage_account.this.name
}

output "storage_container_name" {
  description = "Blob container name for the prod environment."
  value       = azurerm_storage_container.this.name
}

output "vm_private_ip" {
  description = "Private IP address assigned to the prod VM."
  value       = azurerm_network_interface.vm.ip_configuration[0].private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address assigned to the prod VM, if enabled."
  value       = try(azurerm_public_ip.vm[0].ip_address, null)
}
