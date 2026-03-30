terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
  }
}
