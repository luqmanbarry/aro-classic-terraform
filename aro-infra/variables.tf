variable "platform_environment" {
  type = string
  description = "The OCP cluster environment"
  default = "dev"
}

variable "azure_cloud_environment" {
  type = string
  description = "The Azure Cloud Environment. Options: environment=public|usgovernment|china|german"
  validation {
    condition = contains(["environment", "public", "usgovernment", "usgovernmentl4", "usgovernmentl5", "china", "german"], var.azure_cloud_environment)
    error_message = "Expected values are one of: environment, public, usgovernment, usgovernmentl4, usgovernmentl5, china, german"
  }
}

variable "location" {
  type    = string
  default = "eastus"
  description = "The location where the ARO cluster is created"
}

variable "company_name" {
  type = string
  default = "humbleinc"
}

variable "resource_name_suffix" {
  type = string
  default = "platformops"
}

variable "organization" {
  type        = string
  description = "The business unit that owns the cluster"
  default = "sales"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "ocp_version" {
  type        = string
  default     = "4.14.12"
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_name" {
  type        = string
  description = "The name of the ARO cluster to create"
  default = "aro-classic-001"
}

variable "cluster_resource_group" {
  type        = string
  description = "The resource in which to create the cluster"
  default = "aro-classic-001"
}

variable "vnet_cidr" {
  type        = string
  description = "IP Address space of the VNet"
  default = "10.90.0.0/22"
}

variable "main_subnet_cidr" {
  type        = string
  description = "IP Address space of the main subnet"
  default = "10.90.1.0/24"
}

variable "worker_subnet_cidr" {
  type        = string
  description = "IP Address space of the worker subnet"
  default = "10.90.2.0/24"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
    "Contact"        = "lbarry@redhat.com"
  }
  description = "Additional Azure resource tags"
}

variable "inbound_traffic_security_rules" {
  type = list(object({
    name              = string
    source_cidrs      = string
    target_cidrs      = string
    source_port_range = string
    target_port_range = string
    protocol          = string
  }))

  default = [
    {
      name              = "allow-inbound-from-ops-ocp"
      source_cidrs      = "10.254.0.0/24"
      target_cidrs      = "*"
      source_port_range = "30000-32900"
      target_port_range = "*"
      protocol          = "Tcp"
    },
    {
      name              = "allow-inbound-from-vendor-svc"
      source_cidrs      = "10.10.0.0/24"
      target_cidrs      = "*"
      source_port_range = "8000-9000"
      target_port_range = "*"
      protocol          = "Tcp"
    }
  ]
}

variable "redhatopenshift_sp_client_id" {
  type = string
  default = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
  description = "The SP client_id, Red Hat automation uses to build and monitor the cluster."
}

variable "base_dns_zone_name" {
  type = string
  description = "The base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "base_dns_zone_resource_group" {
  type = string
  description = "The resource group of the base DNS zone name; the parent DNS zone name."
  default = "example.com"
}

variable "dns_ttl" {
  type = number
  description = "Default domain DNS TTL"
  default = 3600
}

variable "use_azure_provided_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}