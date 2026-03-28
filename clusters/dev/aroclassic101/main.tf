module "factory_stack" {
  source = "../../../modules/factory-stack"

  providers = {
    kubernetes.acmhub_cluster = kubernetes.acmhub_cluster
  }

  cluster_name                        = var.cluster_name
  class_name                          = var.class_name
  environment                         = var.environment
  azure_region                        = var.azure_region
  azure_cloud_environment             = var.azure_cloud_environment
  openshift_version                   = var.openshift_version
  private_cluster                     = var.private_cluster
  fips_enabled                        = var.fips_enabled
  use_azure_provided_domain           = var.use_azure_provided_domain
  enable_acm_registration             = var.enable_acm_registration
  enable_gitops_bootstrap             = var.enable_gitops_bootstrap
  redhatopenshift_sp_client_id        = var.redhatopenshift_sp_client_id
  default_tags                        = var.default_tags
  business_metadata                   = var.business_metadata
  network                             = var.network
  cluster                             = var.cluster
  key_vault                           = var.key_vault
  gitops                              = var.gitops
  acm                                 = var.acm
  default_kubeconfig_filename         = var.default_kubeconfig_filename
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  acmhub_kubeconfig_filename          = var.acmhub_kubeconfig_filename
  temp_dir                            = var.temp_dir
}
