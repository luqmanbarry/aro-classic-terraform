
variable "platform_environment" {
  type = string
  description = "The ARO cluster environment"
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
  description = "The location where the ARO cluster is created"
}

variable "subscription_id" {
  type = string
  description = "The subscription ID of the business unit org"
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

variable "main_subnet_id" {
  type        = string
  description = "The main subnet ID"
  default = "looked-up"
}

variable "worker_subnet_cidr" {
  type        = string
  description = "IP Address space of the worker subnet"
  default = "10.90.2.0/24"
}

variable "worker_subnet_id" {
  type        = string
  description = "The worker subnet ID"
  default = "looked-up"
}


variable "main_vm_size" {
  type = string
  default = "Standard_D8s_v3"
}

variable "worker_vm_size" {
  type = string
  default = "Standard_D4s_v3"
}

variable "worker_node_count" {
  type = number
  description = "The worker node count"
  default = 3
}

variable "worker_disk_size_gb" {
  type = number
  description = "The worker node disk size in GB"
  default = 3
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
    "Contact"        = "lbarry@redhat.com"
  }
  description = "Default Azure resource tags. Should be set at the admin level."
}

variable "cluster_inbound_network_security_rules" {
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

variable "tfstate_resource_group" {
  type = string
  default = "aro-tfstate"
}

variable "cluster_resource_group" {
  type        = string
  description = "The resource in which to create the cluster"
  default = "aro-classic-001"
}

variable "tfstate_location" {
  type = string
  default = "eastus"
}

variable "tfstate_storage_account_name" {
  type = string
  description = "The tfstate storage account name. It must be globally unique"
}

variable "tfstate_storage_container" {
  type = string
  default = "ocp-tfstate"
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

variable "acmhub_registration_enabled" {
  type = bool
  description = "Do you want the cluster to be registered to ACM-HUB? true or false"
  default = false
}

variable "acmhub_cluster_name" {
  type = string
  default = "rosa-7wc76"
}

variable "acmhub_vault_secret_name" {
  type = string
  default = "openshift-OCP_ENV-acmhub-ACMHUB_CLUSTER_NAME"
}

variable "ocp_pull_secret_vault_path" {
  type = string
  default = "openshift-aro-ocp-pull-secret"
}

variable "git_token_vault_path" {
  type = string
  default = "git-github-pat"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ROSA cluster"
  default = "aro-classic-101"
}

variable "cluster_service_principal" {
  type        = string
  description = "The service principal assigned to the ARO cluster"
  default = "aro-classic-101"
}

variable "cluster_sp_client_id" {
  type        = string
  description = "The cluster Service Principal ID"
  default = "looked-up"
}

variable "organization" {
  type        = string
  description = "The business unit that owns the cluster."
  default = "sales"
}

variable "git_token" {
  type          = string
  description   = "The GitHub Personal Access Token (PAT)"
  default = "my-personal-access-token"
}

variable "git_base_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://github.com/"
}

variable "git_owner" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "luqmanbarry"
}

variable "git_repository_name" {
  type = string
  description = "The GitHub Repository name"
  default = "rosa-sts-terraform"  
}

variable "git_branch" {
  type = string
  description = "The base branch" 
  default = "main" 
}

variable "git_action_taken" {
  type            = string
  description     = "The action the CI Job took: options: ROSAClusterCreate, ROSAClusterUpdate,,,etc"
  default         = "ROSAClusterCreate"
}

variable "private_cluster" {
  type        = bool
  description = "Do you want this cluster to be private? true or false"
  default = false
}

variable "pod_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Pods"
  default = ""
}

variable "service_cidr" {
  type        = string
  description = "value of the CIDR block to use for in-cluster Services"
  default = ""
}

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

variable "acmhub_username" {
  type = string
  default = "changeme"
}

variable "acmhub_password" {
  type = string
  default = "changeme"
}

variable "acmhub_pull_from_vault" {
  type = bool
  default = true
  description = "Whether to pull from Vault or not"
}

variable "acmhub_cluster_env" {
  type = string
  description = "ACMHUB Cluster Environment"
}

variable acmhub_api_server {
  type        = string
  description = "The ACMHUB api server hostname"
  default = ""
}

variable "pull_secret_vault_path" {
  type = string
  default = "openshift-OCP_ENV-pull-secret"
}

variable "root_dns_domain" {
  type = string
  default = "sama-wat.com"
  description = "The root domain name bought"
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

variable "fips_enabled" {
  type        = bool
  default     = false
  description = "Do you want to enable FIPS? true or false"
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

variable "use_azure_provided_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}