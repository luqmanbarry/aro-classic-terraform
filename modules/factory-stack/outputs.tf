output "cluster_name" {
  value = var.cluster_name
}

output "resource_group_name" {
  value = module.aro_classic_infra.resource_group_name
}

output "console_url" {
  value     = module.aro_classic_core.console_url
  sensitive = true
}

output "api_server_url" {
  value     = module.aro_classic_core.api_server_url
  sensitive = true
}

output "custom_dns_domain_name" {
  value = module.aro_classic_infra.custom_dns_domain_name
}
