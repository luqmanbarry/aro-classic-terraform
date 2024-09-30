variable "platform_environment" {
  type = string
  description = "The ROSA cluster environment"
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

variable "organization" {
  type        = string
  description = "The region where the ROSA cluster is created"
  default = "sales"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster to create"
  default = "rosa-sts-001"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
    "Contact"        = "lbarry@redhat.com"
  }
  description = "Additional Azure resource tags"
}

variable "private_cluster" {
  type = bool
  description = "Make the ARO cluster public (internet access) or private"
}

variable "key_vault_name" {
  type = string
  description = "The name of the Azure KV instance hosting OpenShift secrets"
  default = "derived"
}

variable "key_vault_resource_group" {
  type = string
  description = "The RG of the Azure KV instance hosting OpenShift secrets"
  default = "derived"
}