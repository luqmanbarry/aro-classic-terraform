terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.48"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
