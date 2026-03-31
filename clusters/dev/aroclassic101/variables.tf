variable "cluster_name" {
  type = string
}

variable "class_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "azure_region" {
  type = string
}

variable "azure_cloud_environment" {
  type = string
}

variable "openshift_version" {
  type = string
}

variable "private_cluster" {
  type = bool
}

variable "fips_enabled" {
  type = bool
}

variable "use_azure_provided_domain" {
  type = bool
}

variable "enable_acm_registration" {
  type = bool
}

variable "enable_gitops_bootstrap" {
  type = bool
}

variable "managed_identity" {
  type = object({
    enabled = bool
  })
}

variable "infrastructure" {
  type = object({
    create_azure_resources = bool
    existing = optional(object({
      main_subnet_id       = string
      worker_subnet_id     = string
      cluster_sp_client_id = string
    }))
  })
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "redhatopenshift_sp_client_id" {
  type    = string
  default = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}

variable "business_metadata" {
  type = object({
    owner       = string
    cost_center = string
    contact     = string
  })
}

variable "network" {
  type = object({
    vnet_cidr                    = string
    main_subnet_cidr             = string
    worker_subnet_cidr           = string
    pod_cidr                     = string
    service_cidr                 = string
    base_dns_zone_name           = string
    base_dns_zone_resource_group = string
    dns_ttl                      = number
    inbound_traffic_security_rules = list(object({
      name              = string
      source_cidrs      = string
      target_cidrs      = string
      source_port_range = string
      target_port_range = string
      protocol          = string
    }))
  })
}

variable "cluster" {
  type = object({
    resource_group_name = string
    dns_prefix          = string
    main_vm_size        = string
    worker_vm_size      = string
    worker_disk_size_gb = number
    worker_node_count   = number
  })
}

variable "key_vault" {
  type = object({
    name                        = string
    resource_group              = string
    pull_secret_secret_name     = string
    cluster_details_secret_name = string
  })
}

variable "gitops" {
  type = object({
    enabled         = bool
    repository_url  = string
    target_revision = string
    overlay         = string
    root_app_path   = optional(string)
    repo_username   = optional(string)
    repo_password   = optional(string)
    values          = optional(map(any))
  })
}

variable "acm" {
  type = object({
    hub_cluster_secret_name = optional(string)
  })

  validation {
    condition     = !var.enable_acm_registration || try(var.acm.hub_cluster_secret_name != "", false)
    error_message = "When enable_acm_registration is true, acm.hub_cluster_secret_name must be set."
  }
}

variable "default_kubeconfig_filename" {
  type    = string
  default = ".kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type    = string
  default = ".kube/managed-cluster.config"
}

variable "acmhub_kubeconfig_filename" {
  type    = string
  default = ".kube/acmhub.config"
}

variable "temp_dir" {
  type    = string
  default = ".tmp"
}
