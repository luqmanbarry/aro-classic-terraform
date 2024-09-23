terraform {
  required_providers {
    
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3"
    }

  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  # Authentication credentials will be exposed as environment variables
  # export ARM_CLIENT_ID="xxxxxx"
  # export ARM_SUBSCRIPTION_ID="xxxxxx"
  # export ARM_TENANT_ID="xxxxxx"
  # export ARM_CLIENT_SECRET="xxxxxx"
}