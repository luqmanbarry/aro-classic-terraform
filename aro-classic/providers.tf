terraform {
  required_providers {
    
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2"
    }

    # godaddy = {
    #   source = "n3integration/godaddy"
    #   version = "~> 1"
    # }

  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
  }
  # Authentication credentials will be exposed as environment variables
  # export ARM_CLIENT_ID="xxxxxx"
  # export ARM_SUBSCRIPTION_ID="xxxxxx"
  # export ARM_TENANT_ID="xxxxxx"
  # export ARM_CLIENT_SECRET="xxxxxx"
}

provider "azuread" {
  # Authentication crdentials will be provided as env vars
}

# provider "godaddy" {
#   # key     = var.dns_domain_registrar_api_key
#   # secret  = var.dns_domain_registrar_api_secret
# }