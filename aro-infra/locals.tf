locals {

  custom_dns_domain_prefix                         = format("%s.%s.%s.%s", var.cluster_name, var.platform_environment, var.location, var.organization)
  custom_dns_domain_name                           = format("%s.%s", local.custom_dns_domain_prefix, var.base_dns_zone_name)

  derived_tags = {
    "cluster_name"    = var.cluster_name
    "organization"   = var.organization
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
    "created_by"      = data.azuread_user.current.user_principal_name
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )

  tmp_secrets_dir                = "${path.module}/../.tmp"
  cluster_sp_client_id_filename  = "${local.tmp_secrets_dir}/cluster_sp_client_id"
}