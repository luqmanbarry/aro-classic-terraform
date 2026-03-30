terraform {
  required_version = ">= 1.14.0"

  required_providers {
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
