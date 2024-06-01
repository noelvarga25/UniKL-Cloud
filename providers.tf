terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.12.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "random" {}
