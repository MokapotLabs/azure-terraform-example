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
  }
}

provider "random" "this" {}
