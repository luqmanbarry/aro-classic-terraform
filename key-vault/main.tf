# Business Unit dedicated KeyVault
resource "azurerm_resource_group" "bu_keyvault_rg" {
  name        = var.key_vault_resource_group
  location    = var.location
  tags        = local.resource_tags

  lifecycle {
    ignore_changes = [ tags ]
  }
}

# Provision KeyVault Instance
resource "azurerm_key_vault" "bu_keyvault" {
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.bu_keyvault_rg.name
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 30
  purge_protection_enabled        = false
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  public_network_access_enabled   = var.private_cluster ? false : true
  sku_name                        = "standard"
  
  tags                            = local.resource_tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", 
      "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", 
      "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", 
      "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]

    certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", 
      "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]
  }

  timeouts {
    create = "10m"
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [ tags ]
  }
}

data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}