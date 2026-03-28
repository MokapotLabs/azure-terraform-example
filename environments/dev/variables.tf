variable "project_name" {
  description = "Short project identifier used for naming."
  type        = string
  default     = "acme"
}

variable "location" {
  description = "Azure region for the dev environment."
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short region code used in names."
  type        = string
  default     = "eus"
}

variable "address_space" {
  description = "CIDR blocks assigned to the dev VNet."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "workload_subnet_cidr" {
  description = "CIDR block assigned to the workload subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block assigned to the private subnet."
  type        = string
  default     = "10.10.2.0/24"
}

variable "vm_size" {
  description = "Azure VM size for the dev Linux VM."
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
  description = "CIDR ranges allowed to SSH into the dev VM."
  type        = list(string)
  default     = ["203.0.113.10/32"]
}

variable "enable_public_ip" {
  description = "Whether to attach a public IP to the dev VM."
  type        = bool
  default     = true
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
