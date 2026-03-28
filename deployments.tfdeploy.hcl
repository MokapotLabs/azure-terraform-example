# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

deployment "dev" {
  inputs = {
    environment          = "dev"
    project_name         = "acme"
    location             = "eastus"
    location_short       = "eus"
    address_space        = ["10.10.0.0/16"]
    workload_subnet_cidr = "10.10.1.0/24"
    private_subnet_cidr  = "10.10.2.0/24"
    admin_cidrs          = ["203.0.113.10/32"]
    enable_public_ip     = true
  }
}

deployment "prod" {
  inputs = {
    environment          = "prod"
    project_name         = "acme"
    location             = "westeurope"
    location_short       = "weu"
    address_space        = ["10.20.0.0/16"]
    workload_subnet_cidr = "10.20.1.0/24"
    private_subnet_cidr  = "10.20.2.0/24"
    admin_cidrs          = []
    enable_public_ip     = false
  }
}
