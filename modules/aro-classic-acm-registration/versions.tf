terraform {
  required_version = ">= 1.14.0"

  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "~> 2.38"
      configuration_aliases = [kubernetes.acmhub_cluster]
    }
  }
}
