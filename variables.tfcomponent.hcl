# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "client_id" {
  description = "Azure client ID for the workload identity used by a consuming Stack deployment."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID for the workload identity used by a consuming Stack deployment."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID targeted by a consuming Stack deployment."
  type        = string
}

variable "identity_token" {
  description = "HCP Terraform workload identity token passed from a consuming Stack deployment."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)."
  type        = string
}

variable "project_name" {
  description = "Short project identifier used for naming."
  type        = string
  default     = "acme"
}

variable "location" {
  description = "Azure region for the environment."
  type        = string
}

variable "location_short" {
  description = "Short region code used in names."
  type        = string
}

variable "address_space" {
  description = "CIDR blocks assigned to the VNet."
  type        = list(string)
}

variable "workload_subnet_cidr" {
  description = "CIDR block assigned to the workload subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block assigned to the private subnet."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size for the Linux VM."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the Linux VM."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for Linux VM access."
  type        = string
  sensitive   = true
}

variable "admin_cidrs" {
  description = "CIDR ranges allowed to SSH into the VM if a public IP is enabled."
  type        = list(string)
  default     = []
}

variable "enable_public_ip" {
  description = "Whether to attach a public IP to the VM."
  type        = bool
  default     = false
}

variable "storage_container_name" {
  description = "Blob container name created in the environment storage account."
  type        = string
  default     = "appdata"
}

variable "ddos_protection_plan_id" {
  description = "Optional DDoS protection plan ID for the VNet."
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Additional environment-specific tags."
  type        = map(string)
  default     = {}
}
