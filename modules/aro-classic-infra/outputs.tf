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
  value = var.managed_identity_enabled ? null : azuread_service_principal.cluster[0].client_id
}

output "custom_dns_domain_name" {
  value = local.custom_dns_domain_name
}

output "managed_identity_ids" {
  value = {
    for key, identity in azurerm_user_assigned_identity.managed : key => identity.id
  }
}
