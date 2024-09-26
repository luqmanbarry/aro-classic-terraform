locals {
  tags_query = {
    "cluster_name" = var.cluster_name
  }
  
  tmp_secrets_dir                = "${path.module}/../.tmp"
  cluster_sp_client_id_filename  = "${local.tmp_secrets_dir}/cluster_sp_client_id"

  key_vault_id    = data.azurerm_key_vault.bu_keyvault.id

  # USER PROVIDED
  tenant_id                                        = data.azurerm_client_config.current.tenant_id

  # DERIVED VARS
  cluster_resource_group                           = var.cluster_name
  vnet_name                                        = data.azurerm_virtual_network.current_vnet.name
  custom_dns_domain_prefix                         = format("%s.%s.%s.%s", var.cluster_name, var.platform_environment, var.location, var.organization)
  custom_dns_domain_name                           = format("%s.%s", local.custom_dns_domain_prefix, var.base_dns_zone_name)
  inbound_network_security_group_name              = data.azurerm_network_security_group.network_security_group.name
  acmhub_cluster_env                               = var.platform_environment
  cluster_details_vault_secret_name                = replace(replace(var.cluster_details_vault_secret_name, "OCP_ENV", var.platform_environment), "CLUSTER_NAME", var.cluster_name)
  acmhub_details_vault_secret_name                 = replace(replace(var.acmhub_details_vault_secret_name, "OCP_ENV", var.platform_environment), "ACMHUB_NAME", var.acmhub_cluster_name)
  acmhub_vault_secret_name                         = replace(replace(var.acmhub_vault_secret_name, "OCP_ENV", var.platform_environment), "ACMHUB_CLUSTER_NAME", var.acmhub_cluster_name)
  git_token_vault_path                             = replace(var.git_token_vault_path, "OCP_ENV", var.platform_environment)
  pull_secret_vault_path                           = replace(var.pull_secret_vault_path, "OCP_ENV", var.platform_environment)

  derived_tags = {
      "cluster_name"   = var.cluster_name
      "organization"  = var.organization
      "environment"    = var.platform_environment
      "cost_center"    = var.cost_center
      "created_by"     = format("%s (%s)", data.azuread_user.current.user_principal_name, data.azuread_user.current.mail)
  }

  cluster_infra_tags = merge(
    local.derived_tags,
    var.default_tags
  )


  # TFVARs Paths
  admin_tfvars_path                                = format("${path.module}/../tfvars/admin/admin.tfvars")
  final_tfvars_path                                = format("${path.module}/../tfvars/computed/%s/%s/%s.tfvars", var.organization, var.subscription_id, var.cluster_name)
  
  # FINAL OUTPUT
  admin_tfvars_content                            = [
    "#========================= BEGIN: STATIC VARIABLES ===================================",
    file(local.admin_tfvars_path),
    "#========================= END: STATIC VARIABLES ====================================="
  ]

  dynamic_tfvars_content                           = [
      "#%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%",
      format("organization=%q", var.organization),
      format("subscription_id=%q", var.subscription_id),
      format("private_cluster=%s", var.private_cluster),
      format("vnet_name=%q", var.cluster_name),
      format("vnet_cidr=%q", var.vnet_cidr),
      format("main_subnet_cidr=%q", var.main_subnet_cidr),
      format("main_subnet_id=%q", data.azurerm_subnet.main_subnet.id),
      format("worker_subnet_cidr=%q", var.worker_subnet_cidr),
      format("worker_subnet_id=%q", data.azurerm_subnet.worker_subnet.id),
      format("location=%q", var.location),
      format("platform_environment=%q", var.platform_environment),
      format("cluster_name=%q", var.cluster_name),
      format("cluster_details_vault_secret_name=%q", local.cluster_details_vault_secret_name),
      format("acmhub_details_vault_secret_name=%q", local.acmhub_details_vault_secret_name),
      format("cluster_service_principal=%q", var.cluster_name),
      format("cluster_sp_client_id=%q", data.azuread_service_principal.current_cluster.client_id),
      format("cluster_resource_group=%q", local.cluster_resource_group),
      format("cost_center=%q", var.cost_center),
      format("ocp_version=%q", var.ocp_version),
      format("acmhub_registration_enabled=%s", var.acmhub_registration_enabled),
      format("default_kubeconfig_filename=%q", pathexpand(var.default_kubeconfig_filename)),
      format("managed_cluster_kubeconfig_filename=%q", pathexpand(var.managed_cluster_kubeconfig_filename)),
      format("acmhub_kubeconfig_filename=%q", pathexpand(var.acmhub_kubeconfig_filename)),
      format("acmhub_cluster_name=%q", var.acmhub_cluster_name),
      format("main_vm_size=%q", var.main_vm_size),
      format("worker_vm_size=%q", var.worker_vm_size),
      format("worker_node_count=%s", var.worker_node_count),
      format("worker_disk_size_gb=%s", var.worker_disk_size_gb),
      format("tfstate_resource_group=%q", var.tfstate_resource_group),
      format("tfstate_storage_account_name=%q", var.tfstate_storage_account_name),
      format("tfstate_storage_container=%q", var.tfstate_storage_container),
      format("inbound_network_security_group_name=%q", local.inbound_network_security_group_name),
      format("base_dns_zone_name=%q", var.base_dns_zone_name),
      format("base_dns_zone_resource_group=%q", var.base_dns_zone_resource_group),
      format("root_dns_domain=%q", var.root_dns_domain),
      format("fips_enabled=%s", var.fips_enabled),
      format("use_azure_provided_domain=%s", var.use_azure_provided_domain),
      format("custom_dns_domain_prefix=%q", local.custom_dns_domain_prefix),
      format("custom_dns_domain_name=%q", local.custom_dns_domain_name),
      format("key_vault_name=%q", var.key_vault_name),
      format("key_vault_resource_group=%q", var.key_vault_resource_group),
      format("key_vault_id=%q", local.key_vault_id),
      format("pull_secret_vault_path=%q", local.pull_secret_vault_path),
      format("acmhub_cluster_env=%q", local.acmhub_cluster_env),
      format("acmhub_vault_secret_name=%q", local.acmhub_vault_secret_name),
      replace(format("cluster_infra_tags=%v", local.cluster_infra_tags), ":", "="),
      "#%%%%%%%%%%%%%%%%%%%%%%%%% END: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    ]
  
  final_tfvars_content                             = join("\n\n",
    local.admin_tfvars_content, 
    local.dynamic_tfvars_content
  )

}
