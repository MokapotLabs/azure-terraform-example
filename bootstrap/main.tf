data "azurerm_client_config" "current" {}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  state_resource_group_name = coalesce(var.state_resource_group_name, "rg-${var.project_name}-tfstate")
  storage_account_prefix    = substr("${replace(lower(var.project_name), "-", "")}tf", 0, 18)
  storage_account_name      = substr("${local.storage_account_prefix}${random_string.storage_suffix.result}", 0, 24)

  common_tags = merge(var.tags, {
    layer      = "bootstrap"
    location   = var.location
    managed_by = "terraform"
    project    = var.project_name
  })
}

resource "azurerm_resource_group" "state" {
  name     = local.state_resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "state" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "state" {
  name                  = var.state_container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}
