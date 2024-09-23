variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}

variable "acmhub_kubeconfig_filename" {
  type = string
  default = "~/.acmhub_kube/config"
}

variable "acmhub_registration_enabled" {
  type = bool
  description = "Do you want the cluster to be registered to ACM-HUB? true or false"
  default = false
}

variable "cluster_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
}

variable "acmhub_details_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-ACMHUB_NAME-cluster-details"
  description = "The name of the KV secret that will hold the ACMHUB admin details"
}

variable "key_vault_id" {
  type = string
  description = "The Azure KeyVault ID"
  default = "looked-up"
}

