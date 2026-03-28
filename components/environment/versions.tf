terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "mbarcia"

    workspaces {
      tags = ["azure-terraform-interview"]
    }
  }

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
}
