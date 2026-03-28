# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 4.20"
  }
  random = {
    source  = "hashicorp/random"
    version = "~> 3.7"
  }
}

provider "azurerm" "this" {
  config {
    features {}
    use_oidc        = true
    oidc_token      = var.identity_token
    client_id       = var.client_id
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
  }
}

provider "random" "this" {}
