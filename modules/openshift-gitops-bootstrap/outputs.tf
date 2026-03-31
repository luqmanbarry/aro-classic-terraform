output "cluster_name" {
  value = var.cluster_name
}

output "external_secrets_workload_identity_client_id" {
  value = azurerm_user_assigned_identity.external_secrets.client_id
}
