locals {
  default_domain  = format("%s.%s", var.cluster_name, var.organization)
  # default_domain  = "poc-101"
  ocp_pull_secret = "${path.module}/.pull-secret/pull-secret.json"

  tmp_secrets_dir                = "${path.module}/../.tmp"
  console_url_content_path       = "${path.module}/${local.tmp_secrets_dir}/console_url"
  api_server_url_content_path    = "${path.module}/${local.tmp_secrets_dir}/api_server_url"
  admin_username_content_path    = "${path.module}/${local.tmp_secrets_dir}/admin_username"
  admin_password_content_path    = "${path.module}/${local.tmp_secrets_dir}/admin_password"
  ingress_lb_ip_content_path     = "${path.module}/${local.tmp_secrets_dir}/ingress_lb_ip"
  api_server_lb_ip_content_path  = "${path.module}/${local.tmp_secrets_dir}/api_server_lb_ip"

  derived_tags = {
      "organization"   = var.organization
      "environment"     = var.platform_environment
      "cost_center"     = var.cost_center
      "created_by"      = format("%s", data.azuread_user.current.user_principal_name)
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )

  cluster_details = {
    cluster_name      = trimspace(var.cluster_name)
    console_url       = trimspace(data.local_file.console_url.content)
    api_server_url    = trimspace(data.local_file.api_server_url.content)
    admin_username    = trimspace(data.local_file.admin_username.content)
    admin_password    = trimspace(data.local_file.admin_password.content)
    ingress_lb_ip     = trimspace(data.local_file.ingress_lb_ip.content)
    api_server_lb_ip  = trimspace(data.local_file.api_server_lb_ip.content)
  }
}