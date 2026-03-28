output "resource_group_name" {
  value = azurerm_resource_group.cluster.name
}

output "main_subnet_id" {
  value = azurerm_subnet.main.id
}

output "worker_subnet_id" {
  value = azurerm_subnet.worker.id
}

output "key_vault_id" {
  value = data.azurerm_key_vault.target.id
}

output "cluster_sp_client_id" {
  value = azuread_service_principal.cluster.client_id
}

output "custom_dns_domain_name" {
  value = local.custom_dns_domain_name
}
