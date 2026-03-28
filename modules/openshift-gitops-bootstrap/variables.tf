variable "cluster_name" { type = string }
variable "managed_cluster_kubeconfig_filename" { type = string }
variable "gitops_git_repo_url" { type = string }
variable "gitops_target_revision" { type = string }
variable "gitops_root_app_path" { type = string }
variable "gitops_repo_username" { type = string }
variable "gitops_repo_password" { type = string }
variable "gitops_values" { type = any }
