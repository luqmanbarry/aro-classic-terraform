data "azurerm_key_vault" "target" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group
}

locals {
  custom_dns_domain_name = var.use_azure_provided_domain ? "" : "${var.cluster.dns_prefix}.${var.network.base_dns_zone_name}"
  resource_group_name    = var.infrastructure.create_azure_resources ? module.aro_classic_infra[0].resource_group_name : var.cluster.resource_group_name
  main_subnet_id         = var.infrastructure.create_azure_resources ? module.aro_classic_infra[0].main_subnet_id : var.infrastructure.existing.main_subnet_id
  worker_subnet_id       = var.infrastructure.create_azure_resources ? module.aro_classic_infra[0].worker_subnet_id : var.infrastructure.existing.worker_subnet_id
  key_vault_id           = data.azurerm_key_vault.target.id
  cluster_sp_client_id   = var.managed_identity.enabled ? null : (var.infrastructure.create_azure_resources ? module.aro_classic_infra[0].cluster_sp_client_id : var.infrastructure.existing.cluster_sp_client_id)
  managed_identity_ids   = var.managed_identity.enabled && var.infrastructure.create_azure_resources ? module.aro_classic_infra[0].managed_identity_ids : {}
}

module "aro_classic_infra" {
  count  = var.infrastructure.create_azure_resources ? 1 : 0
  source = "../aro-classic-infra"

  cluster_name                 = var.cluster_name
  environment                  = var.environment
  azure_region                 = var.azure_region
  business_metadata            = var.business_metadata
  cluster                      = var.cluster
  network                      = var.network
  key_vault                    = var.key_vault
  use_azure_provided_domain    = var.use_azure_provided_domain
  redhatopenshift_sp_client_id = var.redhatopenshift_sp_client_id
  managed_identity_enabled     = var.managed_identity.enabled
  default_tags                 = var.default_tags
}

module "aro_classic_core" {
  source = "../aro-classic-core"

  cluster_name                 = var.cluster_name
  environment                  = var.environment
  azure_region                 = var.azure_region
  openshift_version            = var.openshift_version
  private_cluster              = var.private_cluster
  fips_enabled                 = var.fips_enabled
  business_metadata            = var.business_metadata
  cluster                      = var.cluster
  network                      = var.network
  key_vault                    = var.key_vault
  use_azure_provided_domain    = var.use_azure_provided_domain
  resource_group_name          = local.resource_group_name
  main_subnet_id               = local.main_subnet_id
  worker_subnet_id             = local.worker_subnet_id
  key_vault_id                 = local.key_vault_id
  cluster_sp_client_id         = local.cluster_sp_client_id
  managed_identity             = var.managed_identity
  managed_identity_ids         = local.managed_identity_ids
  custom_dns_domain_name       = local.custom_dns_domain_name
  base_dns_zone_resource_group = var.network.base_dns_zone_resource_group
  temp_dir                     = "${var.temp_dir}/${var.cluster_name}"
  default_tags                 = var.default_tags
}

module "aro_classic_kubeconfig" {
  source = "../aro-classic-kubeconfig"

  cluster_details_secret_name         = var.key_vault.cluster_details_secret_name
  key_vault_id                        = local.key_vault_id
  default_kubeconfig_filename         = var.default_kubeconfig_filename
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  acmhub_registration_enabled         = var.enable_acm_registration
  acmhub_details_secret_name          = try(var.acm.hub_cluster_secret_name, "")
  acmhub_kubeconfig_filename          = var.acmhub_kubeconfig_filename
}

module "acm_registration" {
  count  = var.enable_acm_registration ? 1 : 0
  source = "../aro-classic-acm-registration"

  providers = {
    kubernetes.acmhub_cluster = kubernetes.acmhub_cluster
  }

  cluster_name                        = var.cluster_name
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
}

module "gitops_bootstrap" {
  count  = var.enable_gitops_bootstrap && var.gitops.enabled ? 1 : 0
  source = "../openshift-gitops-bootstrap"

  cluster_name                        = var.cluster_name
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  gitops_git_repo_url                 = var.gitops.repository_url
  gitops_target_revision              = var.gitops.target_revision
  gitops_root_app_path                = try(var.gitops.root_app_path, "gitops/overlays/${var.gitops.overlay}")
  gitops_repo_username                = try(var.gitops.repo_username, "")
  gitops_repo_password                = try(var.gitops.repo_password, "")
  gitops_values                       = try(var.gitops.values, {})
}
