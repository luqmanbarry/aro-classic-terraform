terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

provider "azurerm" {
  environment = var.azure_cloud_environment

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
}

provider "azuread" {
  environment = var.azure_cloud_environment
}

provider "kubernetes" {
  alias       = "acmhub_cluster"
  config_path = var.acmhub_kubeconfig_filename
}
