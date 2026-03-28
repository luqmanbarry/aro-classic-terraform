output "console_url" {
  value     = local.cluster_details.console_url
  sensitive = true
}

output "api_server_url" {
  value     = local.cluster_details.api_server_url
  sensitive = true
}

output "cluster_details_secret_name" {
  value = azurerm_key_vault_secret.cluster_details.name
}
