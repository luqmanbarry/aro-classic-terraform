
variable "company_name" {
  type = string
  default = "humbleinc"
}

variable "resource_name_suffix" {
  type = string
  default = "platformops"
}

variable "tfstate_resource_group" {
  type = string
  default = "aro-tfstate"
}

variable "tfstate_location" {
  type = string
  default = "eastus"
}

variable "tfstate_storage_account_name" {
  type = string
  description = "The tfstate storage account name. It must be globally unique"
  default = "derived"
}

variable "tfstate_storage_container" {
  type = string
  default = "ocp-tfstate"
}

variable "organization" {
  type = string
  default = "engineering"
  description = "The business unit that owns the resources"
}

variable "cluster_name" {
  type = string
  default = "aro-classic-101"
}

variable "platform_environment" {
  type = string
  default = "dev"
}

variable "cost_center" {
  type = string
  default = "47007"
}

variable "default_tags" {
  default = {
    Terraform   = "true"
    environment = "dev"
    contact     = "lbarry@redhat.com"
  }
  description = "Additional Azure resource tags"
  type        = map(string)
}