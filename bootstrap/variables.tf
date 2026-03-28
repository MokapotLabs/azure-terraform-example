variable "project_name" {
  description = "Short project identifier used in resource names."
  type        = string
  default     = "acme"
}

variable "location" {
  description = "Azure region used for the Terraform state resources."
  type        = string
  default     = "eastus"
}

variable "state_resource_group_name" {
  description = "Optional override for the resource group that stores Terraform state."
  type        = string
  default     = null
}

variable "state_container_name" {
  description = "Blob container name used by the azurerm backend."
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Additional tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}
