output "state_resource_group_name" {
  description = "Resource group that stores Terraform remote state."
  value       = azurerm_resource_group.state.name
}

output "state_storage_account_name" {
  description = "Storage account that stores Terraform remote state."
  value       = azurerm_storage_account.state.name
}

output "state_container_name" {
  description = "Blob container used for Terraform remote state."
  value       = azurerm_storage_container.state.name
}

output "subscription_id" {
  description = "Azure subscription used for the bootstrap deployment."
  value       = data.azurerm_client_config.current.subscription_id
}

output "backend_init_example" {
  description = "Example terraform init command fragment for environment stacks."
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
  }
}
