output "cluster_name" {
  value = module.factory_stack.cluster_name
}

output "resource_group_name" {
  value = module.factory_stack.resource_group_name
}

output "console_url" {
  value     = module.factory_stack.console_url
  sensitive = true
}

output "api_server_url" {
  value     = module.factory_stack.api_server_url
  sensitive = true
}

output "custom_dns_domain_name" {
  value = module.factory_stack.custom_dns_domain_name
}
