terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
      version = "~> 2"
    }
  }
}

provider "kubectl" {
  apply_retry_count  = 10
  config_path        = var.managed_cluster_kubeconfig_filename
  insecure           = true
}
