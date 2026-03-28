terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.42"
    }

    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "~> 2.38"
      configuration_aliases = [kubernetes.acmhub_cluster]
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
